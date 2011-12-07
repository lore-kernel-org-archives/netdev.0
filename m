From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: Fix compile errors if CONFIG_CNIC
 is not set
Date: Wed, 7 Dec 2011 15:53:22 +0200
Message-ID: <1323266002.11998.6.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1323205088-29693-1-git-send-email-mchan@broadcom.com>
 <1323205383.2690.25.camel@edumazet-laptop>
 <1323206734.1762.8.camel@joe2Laptop> <1323207770.7517.7.camel@HP1>
 <1323209811.11998.3.camel@lb-tlvb-eilong.il.broadcom.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Barak Witkowski" <barak@broadcom.com>
To: "Michael Chan" <mchan@broadcom.com>,
	"Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4618 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755810Ab1LGNxg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 08:53:36 -0500
In-Reply-To: <1323209811.11998.3.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-07 at 00:16 +0200, Eilon Greenstein wrote:
> On Tue, 2011-12-06 at 13:42 -0800, Michael Chan wrote:
> > On Tue, 2011-12-06 at 13:25 -0800, Joe Perches wrote:
> > > On Tue, 2011-12-06 at 22:03 +0100, Eric Dumazet wrote:
> > > > Le mardi 06 d=C3=A9cembre 2011 =C3=A0 12:58 -0800, Michael Chan=
 a =C3=A9crit :
> > > > > Don't provide FCoE and iSCSI statistics to management firmwar=
e if
> > > > > CONFIG_CNIC is not set.  Some needed structure fields are not=
 defined
> > > > > without CONFIG_CNIC.
> > > > Thanks for the fast answer, and yes, no more build error :)
> > >=20
> > > That works, but is that the best solution?
> > >=20
> > > Another option is for bnx2x_handle_drv_info_req
> > > to return DRV_MSG_CODE_DRV_INFO_NACK
> > >=20
> >=20
> > Eilon (bnx2x lead maintainer) will need to decide which is the most
> > appropriate solution as he is most familiar with the firmware.  I d=
on't
> > know if sending NACK to the firmware will have other negative effec=
ts or
> > not.  Eilon should be online in about 8 hours and he can send a
> > follow-up patch if necessary.
> >=20
> > > Maybe like:
> > >=20
> > > 	switch (op_code) {
> > > 	case ETH_STATS_OPCODE:
> > > 		bnx2x_drv_info_ether_stat(bp);
> > > 		break;
> > > #ifdef BCM_CNIC
> > > 	case FCOE_STATS_OPCODE:
> > > 		bnx2x_drv_info_fcoe_stat(bp);
> > > 		break;
> > > 	case ISCSI_STATS_OPCODE:
> > > 		bnx2x_drv_info_iscsi_stat(bp);
> > > 		break;
> > > #endif
> > > 	default:
> > > 		/* if op code isn't supported - send NACK */
> > > 		bnx2x_fw_command(bp, DRV_MSG_CODE_DRV_INFO_NACK, 0);
> > > 		return;
> > > 	}
> > >=20
> > >=20
> > >=20
> >=20
>=20
> Joe is right. This latest patch breaks the FW assumption, but at leas=
t
> everything compiles now, so it is not as urgent. We will send a patch=
 in
> that spirit in the morning.

As you probably saw in the patch Barak just sent, after thinking about
it some more and testing the FW flows, it is best to return ACK without
updating the counters.

Eilon

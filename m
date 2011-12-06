From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] bnx2x: Fix compile errors if CONFIG_CNIC is
 not set
Date: Tue, 06 Dec 2011 13:25:34 -0800
Message-ID: <1323206734.1762.8.camel@joe2Laptop>
References: <1323205088-29693-1-git-send-email-mchan@broadcom.com>
	 <1323205383.2690.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, barak@broadcom.com, eilong@broadcom.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:34868 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754290Ab1LFVZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 16:25:37 -0500
In-Reply-To: <1323205383.2690.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-12-06 at 22:03 +0100, Eric Dumazet wrote:
> Le mardi 06 d=C3=A9cembre 2011 =C3=A0 12:58 -0800, Michael Chan a =C3=
=A9crit :
> > Don't provide FCoE and iSCSI statistics to management firmware if
> > CONFIG_CNIC is not set.  Some needed structure fields are not defin=
ed
> > without CONFIG_CNIC.
> Thanks for the fast answer, and yes, no more build error :)

That works, but is that the best solution?

Another option is for bnx2x_handle_drv_info_req
to return DRV_MSG_CODE_DRV_INFO_NACK

Maybe like:

	switch (op_code) {
	case ETH_STATS_OPCODE:
		bnx2x_drv_info_ether_stat(bp);
		break;
#ifdef BCM_CNIC
	case FCOE_STATS_OPCODE:
		bnx2x_drv_info_fcoe_stat(bp);
		break;
	case ISCSI_STATS_OPCODE:
		bnx2x_drv_info_iscsi_stat(bp);
		break;
#endif
	default:
		/* if op code isn't supported - send NACK */
		bnx2x_fw_command(bp, DRV_MSG_CODE_DRV_INFO_NACK, 0);
		return;
	}

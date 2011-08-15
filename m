From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: suppress repeated error messages about Max
 BW
Date: Mon, 15 Aug 2011 21:47:22 +0300
Message-ID: <1313434042.30399.0.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20110812143324.5740.45824.stgit@dhcp-29-224.brq.redhat.com>
 <1313405680.31417.6.camel@lb-tlvb-eilong.il.broadcom.com>
 <4E490A1E.3060209@redhat.com>
 <1313411585.31417.35.camel@lb-tlvb-eilong.il.broadcom.com>
 <4E493798.7010405@redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2057 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752390Ab1HOSrm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 14:47:42 -0400
In-Reply-To: <4E493798.7010405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-15 at 08:13 -0700, Michal Schmidt wrote:
> On 08/15/2011 02:33 PM, Eilon Greenstein wrote:
> > On Mon, 2011-08-15 at 04:59 -0700, Michal Schmidt wrote:
> >> and bnx2x_init_vn_minmax() calls bnx2x_extract_max_cfg() on the gi=
ven
> >> VN, so it seems that the warning can be produced for a non-current=
 VN.
> >
> > You are right, only one function (the PMF) will call this code for =
all
> > functions. But I suspect that if you have zero values, you will hav=
e
> > them for all VNs - is that the case?
>=20
> A tester reported getting only these 4 messages with the patch applie=
d:
>=20
> [bnx2x_extract_max_cfg:1074(eth4)]Illegal configuration detected for =
Max=20
> BW on vn 2 - using 100 instead
> [bnx2x_extract_max_cfg:1074(eth5)]Illegal configuration detected for =
Max=20
> BW on vn 2 - using 100 instead
> [bnx2x_extract_max_cfg:1074(eth6)]Illegal configuration detected for =
Max=20
> BW on vn 3 - using 100 instead
> [bnx2x_extract_max_cfg:1074(eth7)]Illegal configuration detected for =
Max=20
> BW on vn 3 - using 100 instead
>=20
> This suggests that VNs 0 and 1 had non-zero Max BW configuration.

Michal - this is a great point of data! It helped me finding a bug in
that code - the code is not suitable for 4 port devices, it always
assumes 4 VN per PCI function, while in 4 port devices there are only 2
VN per PCI function. I assume that you are seeing this problem on a
57800 with 2x10G + 2x1G - and the 1G devices are in single function mod=
e
and therefore you are seeing this error message. I will send a patch to
fix the problem on 4 port devices soon (after testing it for a while) -
please confirm that you are seeing this issue on 2x10G+2x1G 57800
device.

Now it all makes sense to me - it=E2=80=99s not just misconfigured boar=
d
workaround, this is a real issue :)

Thanks for helping in identifying it!
Eilon




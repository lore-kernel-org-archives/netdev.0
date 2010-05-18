From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system
 (2.6.33.3)
Date: Mon, 17 May 2010 19:11:58 -0700
Message-ID: <1274148718.7893.14.camel@HP1>
References: <C27F8246C663564A84BB7AB3439772421B78147539@IRVEXCHCCR01.corp.ad.broadcom.com>
 <4BF2B3BE.60209@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Krzysztof =?UTF-8?Q?Ol=C4=99dzki?=" <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1217 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754543Ab0ERQYv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 12:24:51 -0400
In-Reply-To: <4BF2B3BE.60209@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2010-05-18 at 08:35 -0700, Krzysztof Ol=C4=99dzki wrote:
> On 2010-05-16 20:51, Michael Chan wrote:
> > Krzysztof Oledzki wrote:
> >
> >>
> >> Why the driver registers 5 interrupts instead of 4? How to
> >> limit it to 4?
> >>
> >
> > The first vector (eth0-0) handles link interrupt and other slow
> > path events.  It also has an RX ring for non-IP packets that are
> > not hashed by the RSS hash.  The majority of the rx packets should
> > be hashed to the rx rings eth0-1 - eth0-4, so I would assign these
> > vectors to different CPUs.
>=20
> Did some more test on a two 4 core CPUs (8 CPUs reported to the syste=
m)=20
> and on a two 4 core CPUs with HT (16 CPUs reported to the system) and=
 in=20
> both cases there are 8 instead of 9 vectors: eth0-0 .. eth0-7 (irqs 6=
1=20
> .. 68). However, dmesg shows that 9 interrupts are allocated:
>=20
> bnx2 0000:01:00.0: irq 61 for MSI/MSI-X
> bnx2 0000:01:00.0: irq 62 for MSI/MSI-X
> bnx2 0000:01:00.0: irq 63 for MSI/MSI-X
> bnx2 0000:01:00.0: irq 64 for MSI/MSI-X
> bnx2 0000:01:00.0: irq 65 for MSI/MSI-X
> bnx2 0000:01:00.0: irq 66 for MSI/MSI-X
> bnx2 0000:01:00.0: irq 67 for MSI/MSI-X
> bnx2 0000:01:00.0: irq 68 for MSI/MSI-X
> bnx2 0000:01:00.0: irq 69 for MSI/MSI-X
>=20
> It such case, which ring will be used for slow path and non-IP packet=
s=20
> and why there is no additional queue like in a 4CPU case?
>=20

eth0-0 is always the one handling slow path, rx ring 0 (non-IP), and tx
ring 0.  The last vector is not used by bnx2.  It is reserved for iSCSI
which is handled by the cnic and bnx2i drivers.



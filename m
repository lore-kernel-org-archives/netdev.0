From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: avoid TX timeout when stopping
 device
Date: Wed, 12 May 2010 14:19:15 +0300
Message-ID: <1273663155.5948.7.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20100512110921.0e3f45fc@dhcp-lab-109.englab.brq.redhat.com>
 <1273656458.2621.22.camel@edumazet-laptop>
 <20100512125815.0dad8ad0@dhcp-lab-109.englab.brq.redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Breno Leitao" <leitao@linux.vnet.ibm.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2208 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751023Ab0ELLTc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 07:19:32 -0400
In-Reply-To: <20100512125815.0dad8ad0@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-05-12 at 03:58 -0700, Stanislaw Gruszka wrote:
> On Wed, 12 May 2010 11:27:38 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le mercredi 12 mai 2010 =C3=A0 11:09 +0200, Stanislaw Gruszka a =C3=
=A9crit :
> > > When stop device call netif_carrier_off() just after disabling TX=
 queue to
> > > avoid possibility of netdev watchdog warning and ->ndo_tx_timeout=
() invocation.
> > >=20
> > > Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
Stanislaw,

I like this patch - it does make a lot of sense. Thanks!

Acked-by: Eilon Greenstein <eilong@broadcom.com>

> > > ---
> >=20
> > This reminds me I saw some strange things in bnx2.c for a similar
> > symptom.
> >=20
> > Commit e6bf95ffa8d6f8f4b7ee33ea01490d95b0bbeb6e
> >=20
> > Would you take a look at this too ?
>=20
> I can send RFC patch for bnx2, and tg3 as I think it needs similar fi=
x.
> =20
> > Or if this kind of trans_start refresh on all queues is really need=
ed,
> > it should be a core network provided function, not implemented on e=
very
> > driver...
>=20
> I think netif_carrier_off() should be used, since touching trans_star=
t make
> timeout only less probable, but not prevent it.=20

Eric,

I thought that your 1ae5dc342ac78d7a42965fd1f323815f6f5ef2c1 commit too=
k
care of trans_start, right? Well, actually the commit that made it
possible to remove the trans_start manipulation.

Eilon



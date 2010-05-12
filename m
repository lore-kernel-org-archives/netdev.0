From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH net-next] bnx2x: avoid TX timeout when stopping device
Date: Wed, 12 May 2010 12:58:15 +0200
Message-ID: <20100512125815.0dad8ad0@dhcp-lab-109.englab.brq.redhat.com>
References: <20100512110921.0e3f45fc@dhcp-lab-109.englab.brq.redhat.com>
	<1273656458.2621.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755528Ab0ELK4K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 06:56:10 -0400
In-Reply-To: <1273656458.2621.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 May 2010 11:27:38 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 12 mai 2010 =C3=A0 11:09 +0200, Stanislaw Gruszka a =C3=A9=
crit :
> > When stop device call netif_carrier_off() just after disabling TX q=
ueue to
> > avoid possibility of netdev watchdog warning and ->ndo_tx_timeout()=
 invocation.
> >=20
> > Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> > ---
>=20
> This reminds me I saw some strange things in bnx2.c for a similar
> symptom.
>=20
> Commit e6bf95ffa8d6f8f4b7ee33ea01490d95b0bbeb6e
>=20
> Would you take a look at this too ?

I can send RFC patch for bnx2, and tg3 as I think it needs similar fix.
=20
> Or if this kind of trans_start refresh on all queues is really needed=
,
> it should be a core network provided function, not implemented on eve=
ry
> driver...

I think netif_carrier_off() should be used, since touching trans_start =
make
timeout only less probable, but not prevent it.=20

Stanislaw

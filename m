From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 V2] kaweth: Fix locking to be SMP-safe
Date: Tue, 31 Mar 2009 15:10:28 -0700 (PDT)
Message-ID: <20090331.151028.42671906.davem@davemloft.net>
References: <49d264dd.YwbXLw18YaD1tQqD%Larry.Finger@lwfinger.net>
	<200904010013.05494.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry.Finger@lwfinger.net, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757669AbZCaWKk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 18:10:40 -0400
In-Reply-To: <200904010013.05494.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Oliver Neukum <oliver@neukum.org>
Date: Wed, 1 Apr 2009 00:13:04 +0200

> Am Dienstag 31 M=E4rz 2009 20:45:49 schrieb Larry Finger:
>=20
> > @@ -796,7 +799,7 @@ static int kaweth_start_xmit(struct sk_b
>=20
> > @@ -848,7 +851,7 @@ skip:
> >  		net->trans_start =3D jiffies;
> >  	}
> >
> > -	spin_unlock(&kaweth->device_lock);
> > +	spin_unlock_irq(&kaweth->device_lock);
>=20
> Here you enable interrupts. Are you sure ndo_start_xmit is never
> called with interrupts disabled?

It must never be invoked that way, this would break so many
drivers.

On the other hand, all of these driver paths never execute
in a real hardware interrupt context, the deepest it gets
into is software interrupts.  So spin_*lock*_bh() might be
more appropriate.

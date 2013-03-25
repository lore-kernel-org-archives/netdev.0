From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 3/3] dsa: fix freeing of sparse port allocation
Date: Mon, 25 Mar 2013 20:55:33 +0100
Message-ID: <201303252055.33840.florian@openwrt.org>
References: <1364223820-26051-1-git-send-email-florian@openwrt.org> <1364223820-26051-4-git-send-email-florian@openwrt.org> <AE90C24D6B3A694183C094C60CF0A2F6026B71B3@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "David Laight" <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:62744 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933000Ab3CYTzl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 15:55:41 -0400
Received: by mail-wg0-f47.google.com with SMTP id dt14so3473790wgb.26
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 12:55:40 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B71B3@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 mars 2013 17:03:23, David Laight a =E9crit :
> > If we have defined a sparse port allocation which is non-contiguous=
 and
> > contains gaps, the code freeing port_names will just stop when it
> > encouters a first NULL port_names, which is not right, we should it=
erate
> > over all possible number of ports (DSA_MAX_PORTS) until we are done=
=2E
>=20
> ...
>=20
> >  		port_index =3D 0;
> >=20
> > -		while (pd->chip[i].port_names &&
> > -			pd->chip[i].port_names[++port_index])
> > -			kfree(pd->chip[i].port_names[port_index]);
> > +		while (port_index < DSA_MAX_PORTS) {
> > +			if (pd->chip[i].port_names[port_index])
> > +				kfree(pd->chip[i].port_names[port_index]);
> > +			port_index++;
> > +		}
>=20
> A couple of 'odd' differences:
>=20
> The old code checked pd->chip[i].port_names (as if it
> might be a pointer) that is absent from the new version.
> (If it is separately allocated it is leaked).
>=20
> The new code tests and frees pd->chip[i].port_names[0]
> whereas the old code ignored the 0th entry.

The old code was wrong, it was off by one for the first array index, an=
d would=20
stop whenever it encountered the first NULL port_names[index] so we wou=
ld not=20
skip other these and free the possibly non-NULL next one.

I think the current code is now correct, but thanks for the review!
--
=46lorian

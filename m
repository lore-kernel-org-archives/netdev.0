From: <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next 3/5] be2net: fix erx->rx_drops_no_frags wrap
 around
Date: Mon, 22 Aug 2011 10:22:13 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F642D8F500F6@EXMAIL.ad.emulex.com>
References: <1314011613-4519-1-git-send-email-sathya.perla@emulex.com>
	 <1314011613-4519-4-git-send-email-sathya.perla@emulex.com>
	 <1314013414.2307.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1314013658.2307.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <3367B80B08154D42A3B2BC708B5D41F642D8EDB85A@EXMAIL.ad.emulex.com>,<1314017087.2307.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:17646 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752254Ab1HVR0F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 13:26:05 -0400
In-Reply-To: <1314017087.2307.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, thanks Eric. I'll re-spin this patch series ...

-Sathya
________________________________________
=46rom: Eric Dumazet [eric.dumazet@gmail.com]
Sent: Monday, August 22, 2011 6:14 PM
To: Perla, Sathya
Cc: netdev@vger.kernel.org
Subject: RE: [PATCH net-next 3/5] be2net: fix erx->rx_drops_no_frags wr=
ap around

Le lundi 22 ao=FBt 2011 =E0 05:15 -0700, Sathya.Perla@Emulex.Com a =E9c=
rit :
> >-----Original Message-----
> >From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> >Sent: Monday, August 22, 2011 5:18 PM
> >
> >Le lundi 22 ao=FBt 2011 =E0 13:43 +0200, Eric Dumazet a =E9crit :
> >
> >> This adds a race for lockless SNMP readers (in be_get_stats64())
> >>
> >> They can see the 32bit value going backward.
> >>
> >> You have to be very careful to read the *acc once, and write it on=
ce.
> >
> >The "write once" is the only requirement.
> >
> >Something like :
> >
> >u32 newval =3D hi(*acc) + val;
> >
> >if (wrapped)
> >     newval +=3D 65536;
> >ACCESS_ONCE(*acc) =3D newval;
> >
>
> Eric,
>
> I'm wondering why you'd need ACCESS_ONCE() here? Wouldn't using the t=
emp variable (newval) as you suggested,
> ensure that the reader doesn't see a half-baked value?
>

If you write :

u32 newval =3D hi(*acc) + val;
if (wrapped)
        newval +=3D 65536;
*acc =3D newval;


C compiler (gcc) is free to eliminate the temp variable and to generate
same code than :

*acc =3D hi(*acc) + val;
if (wrapped)
        *acc +=3D 65536;

ACCESS_ONCE() here is the clean way (and self explanatory/documented) t=
o
keep compiler to write to *acc twice.




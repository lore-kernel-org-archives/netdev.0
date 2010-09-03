From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sctp: implement SIOCINQ ioctl() (take 2)
Date: Fri, 03 Sep 2010 15:28:16 +0200
Message-ID: <1283520496.2453.784.camel@edumazet-laptop>
References: <1283476464-14341-1-git-send-email-flameeyes@gmail.com>
	 <1283496928.3699.1581.camel@edumazet-laptop>
	 <1283517564.8231.0.camel@yamato.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Diego Elio =?ISO-8859-1?Q?Petten=F2?= <flameeyes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42040 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210Ab0ICN2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 09:28:25 -0400
Received: by wwj40 with SMTP id 40so2578876wwj.1
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 06:28:21 -0700 (PDT)
In-Reply-To: <1283517564.8231.0.camel@yamato.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 septembre 2010 =C3=A0 14:39 +0200, Diego Elio Petten=C3=B2=
 a
=C3=A9crit :
> Il giorno ven, 03/09/2010 alle 08.55 +0200, Eric Dumazet ha scritto:
> >=20
> >=20
> > why use an 'unsigned long', since user pointer is a 'int *' ?=20
>=20
> I really just picked up the basic SIOCINQ from UDP/RDP
>=20

I see, dont copy it then :)

net/ipv4/udp.c is right :

        case SIOCOUTQ:
        {
                int amount =3D sk_wmem_alloc_get(sk);

                return put_user(amount, (int __user *)arg);
        }

        case SIOCINQ:
        {
                unsigned int amount =3D first_packet_length(sk);

                if (amount)
                        /*
                         * We will only return the amount
                         * of this packet since that is all
                         * that will be read.
                         */
                        amount -=3D sizeof(struct udphdr);

                return put_user(amount, (int __user *)arg);
        }


Lets try to make it right too for sctp ;)

Thanks



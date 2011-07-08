From: Roland Dreier <roland@purestorage.com>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 8 Jul 2011 12:26:17 -0700
Message-ID: <CAL1RGDWbCi_nE8tRp9zyX3Z1yBHKP9ygxNV6TNKp4Up+0g2EPA@mail.gmail.com>
References: <mj+md-20110708.173556.16517.nikam@ucw.cz> <20110708.104739.169518036069870432.davem@davemloft.net>
 <CABrhC0kaRCpvmKw=TdPZ+7dRFzdcrjF7hoc-VhbtAfXu=WBU_Q@mail.gmail.com> <20110708.110659.1816173367050101549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johnwheffner@gmail.com, mj@ucw.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog106.obsmtp.com ([74.125.245.80]:43902 "HELO
	na3sys010aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752168Ab1GHT0i convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2011 15:26:38 -0400
Received: by mail-qw0-f50.google.com with SMTP id 5so1353464qwe.37
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 12:26:37 -0700 (PDT)
In-Reply-To: <20110708.110659.1816173367050101549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2011 at 11:06 AM, David Miller <davem@davemloft.net> wro=
te:
> Ok, there was also an unintended bug in my original patch,
> I lost the bottom 8 bits in the fold, the hash function
> should instead be:
>
> +static inline u32 arp_hashfn(u32 key, const struct net_device *dev, =
u32 hash_rnd)
> +{
> + =A0 =A0 =A0 u32 val =3D key ^ dev->ifindex ^ hash_rnd;
> +
> + =A0 =A0 =A0 return val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24);
> +}

Doesn't seem to matter much -- this is now equivalent to

      a =3D key ^ dev->ifindex
       return (a ^ (a >> 8) ^ (a >> 16) ^ (a >> 24))           // (1)
            ^ (rnd ^ (rnd >> 8) ^ (rnd >> 16) ^ (rnd >> 24))   // (2)

where again the attacker controls (1), and (2) is a constant.

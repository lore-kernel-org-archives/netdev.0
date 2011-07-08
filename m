From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 8 Jul 2011 22:10:13 +0200
Message-ID: <CAHXqBFL6fT2V0iFTN1mJmQjEVUEfGEAQVOS=Y46BREUr_KWoow@mail.gmail.com>
References: <20110708.122742.1006323245708104141.davem@davemloft.net>
	<CAHXqBFKE_hLvFgL1_7F+k+pQ0+tEuhBqeRUOtgaM1yrjvXQQww@mail.gmail.com>
	<20110708.125118.886216418938741383.davem@davemloft.net>
	<20110708.125912.1535057393082512441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland@purestorage.com, johnwheffner@gmail.com, mj@ucw.cz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:49767 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896Ab1GHUKO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 16:10:14 -0400
Received: by qwk3 with SMTP id 3so1111243qwk.19
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 13:10:13 -0700 (PDT)
In-Reply-To: <20110708.125912.1535057393082512441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/8 David Miller <davem@davemloft.net>:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 08 Jul 2011 12:51:18 -0700 (PDT)
>
>> From: Micha=B3 Miros=B3aw <mirqus@gmail.com>
>> Date: Fri, 8 Jul 2011 21:39:18 +0200
>>
>>> With b[3] =3D b[0] ^ b[1] ^ b[2] you get 2^24 keys that hash to the=
 same bucket.
>>
>> Ok, I'm convinced, thanks :-)
>
> Although, actually it's not this simple. =A0The attack doesn't work.
>
> As they "attack" us, the ARP hash table grows and thus the hash mask
> changes to match. =A0Then his old collisions won't collide any more.
>
> We could even adjust the fold shifts as the table grows to make this
> effect even more pronounced.

There will still be 2^32/n_buckets known values that hash to the same
bucket for every n_buckets. So if the attacker knows when and how the
hash size changes, he can adapt accordingly. It should be easier to
see when you get rid of the XOR [random, but] constant part.

Best Regards,
Micha=B3 Miros=B3aw

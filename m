From: John Heffner <johnwheffner@gmail.com>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 8 Jul 2011 14:03:45 -0400
Message-ID: <CABrhC0kaRCpvmKw=TdPZ+7dRFzdcrjF7hoc-VhbtAfXu=WBU_Q@mail.gmail.com>
References: <20110708.101056.89960389404725087.davem@davemloft.net>
	<mj+md-20110708.173556.16517.nikam@ucw.cz>
	<20110708.104739.169518036069870432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mj@ucw.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39044 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab1GHSDr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 14:03:47 -0400
Received: by eyx24 with SMTP id 24so746436eyx.19
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 11:03:46 -0700 (PDT)
In-Reply-To: <20110708.104739.169518036069870432.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2011 at 1:47 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Martin Mares <mj@ucw.cz>
> Date: Fri, 8 Jul 2011 19:40:55 +0200
>
>> The hash function is linear, so it can be reduced to:
>>
>> =A0 =A0 =A0 a =3D key ^ dev->ifindex
>> =A0 =A0 =A0 return (a >> 8) ^ (a >> 16) ^ (a >> 24) =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 // (1)
>> =A0 =A0 =A0 =A0 =A0 =A0^ (hash_rnd >> 8) ^ (hash_rnd >> 16) ^ (hash_=
rnd >> 24) =A0 =A0// (2)
>
> Is this really the same? =A0The inclusion of a full 32-bit xor
> with hash_rnd before folding was intentional, so that the
> final folding occurs on a completely "random" value.

Martin's reduction looks exactly correct to me.

  -John

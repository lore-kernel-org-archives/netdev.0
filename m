From: David Miller <davem@davemloft.net>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Thu, 06 May 2010 22:04:43 -0700 (PDT)
Message-ID: <20100506.220443.135536330.davem@davemloft.net>
References: <1273085598.2367.233.camel@edumazet-laptop>
	<i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	<1273147586.2357.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhaskie@gmail.com, shemminger@vyatta.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34290
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751235Ab0EGFEg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 May 2010 01:04:36 -0400
In-Reply-To: <1273147586.2357.63.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 May 2010 14:06:26 +0200

> Le jeudi 06 mai 2010 =E0 17:25 +0530, Bhaskar Dutta a =E9crit :
>=20
>> I put in the above change and ran some load tests with around 50
>> active TCP connections doing MD5.
>> I could see only 1 bad packet in 30 min (earlier the problem used to
>> occur instantaneously and repeatedly).
>>=20
>> I think there is another possibility of being preempted when calling
>> tcp_alloc_md5sig_pool()
>> this function releases the spinlock when calling __tcp_alloc_md5sig_=
pool().
>>=20
>> I will run some more tests after changing the  tcp_alloc_md5sig_pool
>> and see if the problem is completely resolved.
>>=20
>=20
> This code should be completely rewritten for linux-2.6.35, its very u=
gly
> and over complex, yet it is not scalable.
>=20
> It could use true percpu data, with no central lock or refcount.

Yes I've always disliked the way the TCP MD5 pool stuff is coded, it's
frankly crap and this is like the 5th major bug that had to get fixed
in it. :-)

But let's fix this as simply as possible in net-2.6 and -stable, so Eri=
c
let me know when you have a tested patch for me to apply.

Thanks a lot!


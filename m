From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Thu, 10 Jan 2008 17:06:53 -0800
Message-ID: <23761.1200013613@death>
References: <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com> <20080109220534.GA2692@gondor.apana.org.au> <7603.1199920750@death> <20080110005809.GA3851@gondor.apana.org.au> <20080110145144.GH8728@gospo.usersys.redhat.com> <20080110203604.GB16621@gondor.apana.org.au> <25832.1199998246@death> <20080110210353.GI8728@gospo.usersys.redhat.com> <20080110210507.GA17344@gondor.apana.org.au>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:57944 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755791AbYAKBHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 20:07:00 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0B18llw010125
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 20:08:47 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0B16vf0117024
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 20:06:57 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0B16uvC018755
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 20:06:57 -0500
In-reply-to: <20080110210507.GA17344@gondor.apana.org.au> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:

>On Thu, Jan 10, 2008 at 04:03:53PM -0500, Andy Gospodarek wrote:
>>
>> > >Sure, but where do you call that function while holding the bond lock?
>> > 
>> > 	If I recall correctly, the problem was that tg3, et al, did
>> > things that might sleep, and bonding was calling from a timer context,
>> > which couldn't sleep.  It wasn't about the lock.
>> 
>> Exactly, I was just about to post the same.
>
>In other words, changing read_lock on bond->lock to read_lock_bh doesn't
>affect this one bit.

	For the case of the bond_set_multicast_list function, changing
the existing write_lock to a read_lock_bh doesn't affect any calls to
dev_set_mac_address (since it isn't called from there) and, apparently,
also resolves the lockdep warning.  I'm still trying to get lockdep to
generate the warning for me locally; I'm not sure which magic thing I'm
missing.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

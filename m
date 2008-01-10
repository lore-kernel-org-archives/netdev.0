From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Thu, 10 Jan 2008 12:50:46 -0800
Message-ID: <25832.1199998246@death>
References: <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com> <20080109220534.GA2692@gondor.apana.org.au> <7603.1199920750@death> <20080110005809.GA3851@gondor.apana.org.au> <20080110145144.GH8728@gospo.usersys.redhat.com> <20080110203604.GB16621@gondor.apana.org.au>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:39561 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbYAJUut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 15:50:49 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0AKonbd006038
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:50:49 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0AKomdm088184
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 13:50:49 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0AKol59018628
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 13:50:48 -0700
In-reply-to: <20080110203604.GB16621@gondor.apana.org.au> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:

>On Thu, Jan 10, 2008 at 09:51:44AM -0500, Andy Gospodarek wrote:
>>
>> That wasn't the only purpose, Herbert.  Making sure that calls to
>> dev_set_mac_address were called from process context was important at
>> the time of the coding as well since at least the tg3 driver took locks
>> that could not be taken reliably in soft-irq context.  Michael Chan
>> fixed this here:
>
>Sure, but where do you call that function while holding the bond lock?

	If I recall correctly, the problem was that tg3, et al, did
things that might sleep, and bonding was calling from a timer context,
which couldn't sleep.  It wasn't about the lock.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

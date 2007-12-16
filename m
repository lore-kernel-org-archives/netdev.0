From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Sun, 16 Dec 2007 19:06:41 +0100
Message-ID: <47656931.1040309@gmail.com>
References: <E1J35d6-00041l-00@gondolin.me.apana.org.au>	<20071214002209.ac748206.akpm@linux-foundation.org>	<20071214083037.GA15602@gondor.apana.org.au>	<20071214.111514.03773174.davem@davemloft.net>	<20071214151136.ae0f969b.akpm@linux-foundation.org>	<20071215041827.GC25324@gondor.apana.org.au>	<20071214214418.0ecd5e67.akpm@linux-foundation.org>	<20071215061021.GA26247@gondor.apana.org.au> <20071215024810.20b8a5ae.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:55342 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbXLPSE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 13:04:57 -0500
Received: by fg-out-1718.google.com with SMTP id e21so196845fga.17
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2007 10:04:55 -0800 (PST)
In-Reply-To: <20071215024810.20b8a5ae.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote, On 12/15/2007 11:48 AM:

> On Sat, 15 Dec 2007 14:10:21 +0800 Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>> On Fri, Dec 14, 2007 at 09:44:18PM -0800, Andrew Morton wrote:
>>> That sounds like a bug in mutex_trylock() to me.
>> I was relying on
>>
>> 	http://kerneltrap.org/mailarchive/linux-netdev/2007/9/28/325129
>>
>> which seems to be a bogus claim now that I actually look at the
>> source code.  So in that case I'm OK with your patch as long as
>> it warns about hard IRQ usage.
> 
> When Eric said
> 
>> Way way deep in mutex debugging on the slowpath there is a unreadable
>> and incomprehensible WARN_ON in muxtex_trylock that will trigger if
>> you have 10 tons of debugging turned on, and you are in,
>> interrupt context, and you manage to hit the slow path.  I think that
>> is a pretty unlikely scenario.
> 
> I think he's still right.  That's if the warning which he managed to find
> even still exists.


It seemed to exist a few days ago:
http://kerneltrap.org/mailarchive/linux-netdev/2007/12/4/473123

Btw., I don't know which of the patches: Eric's or yours will be chosen,
but, IMHO, there is no reason to remove rtnl_trylock(), which can be still
useful, just like mutex_trylock() is.

Regards,
Jarek P.

From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13627] New: Tunnel device ignores TCP/UDP
 traffic
Date: Fri, 26 Jun 2009 19:22:47 -0700 (PDT)
Message-ID: <20090626.192247.17381002.davem@davemloft.net>
References: <bug-13627-10286@http.bugzilla.kernel.org/>
	<20090626124444.c24d9b38.akpm@linux-foundation.org>
	<20090627020403.GB19639@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	olver@hartkopp.net, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pm@debian.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58754
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754424AbZF0CWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 22:22:42 -0400
In-Reply-To: <20090627020403.GB19639@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 27 Jun 2009 10:04:03 +0800

> On Fri, Jun 26, 2009 at 12:44:44PM -0700, Andrew Morton wrote:
>>
>> It's a post-2.6.30 regression which Paul has bisected down to
>> 
>>   commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
>>   Author:     Herbert Xu <herbert@gondor.apana.org.au>
>>   AuthorDate: Mon Jun 22 02:25:25 2009 +0000
>>   Commit:     David S. Miller <davem@davemloft.net>
>>   CommitDate: Tue Jun 23 16:36:25 2009 -0700
>> 
>>       net: Move rx skb_orphan call to where needed
>> 
>> (thanks for doing the bisection!)
> 
> Doh, I'd forgotten about transparent proxying.
> 
> inet: Call skb_orphan before tproxy activates
> 
> As transparent proxying looks up the socket early and assigns
> it to the skb for later processing, we must drop any existing
> socket ownership prior to that in order to distinguish between
> the case where tproxy is active and where it is not.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

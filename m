From: Ben Greear <greearb@candelatech.com>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Fri, 05 Jan 2007 12:33:43 -0800
Message-ID: <459EB627.5040606@candelatech.com>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com>	<E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, dlstevens@us.ibm.com, jarkao2@o2.pl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:39459 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734AbXAEUfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jan 2007 15:35:08 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20070104.123333.91315611.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 04 Jan 2007 17:26:27 +1100
> 
>> David Stevens <dlstevens@us.ibm.com> wrote:
>>>        You're right, I don't know whether it'll fix the problem Ben saw
>>> or not, but it looks like the original code can do a receive before the
>>> in_device is fully initialized, and that, of course, is bad.
>>>        If the device for ip_rcv() is not the same one we were
>>> initializing when the receive interrupted, then the patch should have
>>> no effect either way -- I don't think it'll hide other problems.
>>>        If it's hard to reproduce (which I guess is true), then you're
>>> right, no soft lockup doesn't really tell us if it's fixed or not.
>> Actually I missed your point that the multicast locks aren't even
>> initialised at that point.  So this does explain the soft lock-up
>> and therefore your patch is clearly the correct solution.
> 
> I agree too, therefore I've added David's patch as below.
> 
> I'll push this to the -stable branches as well.  This fix is
> correct even if it does not entirely clear up the soft lockup
> bug being discussed in this thread, but I think it will :-)

We were able to reproduce the problem twice on the un-patched 2.6.18.2 kernel in about
2 hours of our stress test yesterday.  I applied this patch (well, the
ipv4 part..the ipv6 won't apply to 2.6.18.2), and it has run the stress
test clean for a total of about 8 hours.

So, I do believe this was the problem we were hitting, and it seems fixed.

Thanks!
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


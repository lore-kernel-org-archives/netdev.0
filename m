From: Joyce Yu <Joyce.Yu@Sun.COM>
Subject: Re: [Fwd: [PATCH] [NIU] VLAN does not work with niu driver]
Date: Mon, 19 Oct 2009 15:12:49 -0700
Message-ID: <4ADCE461.9080809@Sun.COM>
References: <4AD89D9A.7090405@Sun.COM>
 <20091016.174008.193713863.davem@davemloft.net>
Reply-To: Joyce.Yu@Sun.COM
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brmea-mail-4.Sun.COM ([192.18.98.36]:47413 "EHLO
	brmea-mail-4.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410AbZJSWMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 18:12:46 -0400
Received: from fe-amer-10.sun.com ([192.18.109.80])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n9JMCoPk008320
	for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 22:12:50 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KRS005007WMET00@mail-amer.sun.com> for netdev@vger.kernel.org; Mon,
 19 Oct 2009 16:12:50 -0600 (MDT)
In-reply-to: <20091016.174008.193713863.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here was what happened to this patch:

I got system hard hung a couple of times when testing the niu driver 
with "__pskb_pull_tail(skb, min(len, VLAN_ETH_HLEN))" fix. I thought 
that the fix was not working at the time, so I came up with the fixes 
moving around the pointers. I didn't see the hard hung with that code. 
When you asked me to explain the fix, I had the second thought to 
re-test the "__pskb_pull_tail(skb, min(len, VLAN_ETH_HLEN))" fix. I 
didn't experience any hard hung any more. I also asked our QA to test it 
and didn't find any problem. I guess the hard hung may due to 
rmmod/insmod, ifconfig up/down using different fixes so many times and 
that may cause memory corruptions.

Regards,
Joyce


On 10/16/09 05:40 PM, David Miller wrote:
> From: Joyce Yu <Joyce.Yu@Sun.COM>
> Date: Fri, 16 Oct 2009 09:21:46 -0700
> 
>> Can this patch be accepted and integrated to the main tree?
> 
> Well, what happened to all of those page fragment modifications?
> 
> They all of a sudden are no longer necessary?  Why?
> 
> I'm not going to apply this patch until you start explaining
> why these things are being done, or not done.  And you must
> add some more text to your commit messages so that you explain
> your change sufficiently.
> 
> Thank you.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 


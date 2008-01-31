From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] [1/1] Deprecate tcp_tw_{reuse,recycle}
Date: Wed, 30 Jan 2008 22:37:47 -0800
Message-ID: <47A16CBB.3000409@candelatech.com>
References: <20080130938.523292915@suse.de> <47A0CE75.5080200@candelatech.com> <200801310359.07362.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:44656 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbYAaGhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 01:37:53 -0500
In-Reply-To: <200801310359.07362.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> On Wednesday 30 January 2008 20:22, Ben Greear wrote:
>
>   
>> We use these features to enable creating very high numbers of short-lived
>> TCP connections, primarily used as a test tool for other network
>> devices.
>>     
>
> Hopefully these other network devices don't do any NAT then
> or don't otherwise violate the IP-matches-PAWS assumption.
> Most likely they do actually, so enabling TW recycle
> for testing is probably not even safe for you.
>
> Modern systems have a lot of RAM so even without tw recycle
> you should be able to get a very high number of connections.
> An timewait socket is around 128 bytes on 64bit; this means
> with a GB of memory you can already support > 8 Million TW sockets.
> On 32bit it's even more.
>   
I believe the problem was that all of my ports were used up with
TIME_WAIT sockets and so it couldn't create more.  My test
case was similar to this:

1 Have one machine B listen for connections on one interface (one IP).
2 Have one machine A make a connection to B, and close connection 
immediately or soon after
  it was established.
goto 2

The goal was to make a maximum number of TCP connections per second.  
The data passed
is just filler, and for the fastest settings, we don't pass data at all. 
  Without setting
tcp_tw_recycle to 1, the system could do only a few thousand connections 
per second.  With
it set to 1, I think I was getting around 10,000.  Either way, it was 
significantly faster than
w/out recycle enabled.

So, is there a better way to max out the connections per second without 
having to use tcp_tw_recycle?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com



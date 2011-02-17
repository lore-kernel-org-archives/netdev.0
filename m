From: David Miller <davem@davemloft.net>
Subject: Re: state of rtcache removal...
Date: Wed, 16 Feb 2011 19:27:51 -0800 (PST)
Message-ID: <20110216.192751.104051014.davem@davemloft.net>
References: <20110216.160838.39164069.davem@davemloft.net>
	<AANLkTi=W=1ZiP4JOJwo=FccNA9aK=1bpRn=zkepXXMzi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752546Ab1BQD1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 22:27:16 -0500
In-Reply-To: <AANLkTi=W=1ZiP4JOJwo=FccNA9aK=1bpRn=zkepXXMzi@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 16 Feb 2011 18:59:35 -0800

> On Wed, Feb 16, 2011 at 4:08 PM, David Miller <davem@davemloft.net> wrote:
>>
>> So I've been testing out the routing cache removal patch to see
>> what the impact is on performance.
>>
> Interesting results.
> 
> I assume that this test is purposely using sento on a connected socket
> to force sendmsg to go through the route lookup :-), so this is
> showing what the benefits of rtcache are is when cache hit rate is
> 100%.  For comparison, it might interesting to see what the
> performance is when rate is < 100%.  For instance, we often see hit
> rates < 20% on front end servers.  This could be done flooding to
> random addresses in 10/8 or even 0/0...  I'm hoping that without the
> rtcache performance actually improves in that case!

We know that the performance will be higher in the "closer to %0"
situation, ie.  for DoS workloads.  Because all of the route cache
management overhead goes away.

Anyways I'm working on some ideas to make the high hit rate case
perform amicably again.

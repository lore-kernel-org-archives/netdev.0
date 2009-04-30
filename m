From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
	sk_buff state
Date: Thu, 30 Apr 2009 10:59:13 -0700
Message-ID: <20090430175913.GA12737@cuplxvomd02.corp.sa.net>
References: <20090429222809.GA1949@cuplxvomd02.corp.sa.net> <20090429.154406.231161665.davem@davemloft.net> <20090430163200.GC15170@cuplxvomd02.corp.sa.net> <20090430.094614.13889468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:35920 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934369AbZD3R7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 13:59:15 -0400
Content-Disposition: inline
In-Reply-To: <20090430.094614.13889468.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 09:46:14AM -0700, David Miller wrote:
> From: David VomLehn <dvomlehn@cisco.com>
> Date: Thu, 30 Apr 2009 09:32:00 -0700
> 
> > I think the size is very doable. Only two bits are needed to encode
> > the state so the ability to check the state isn't an issue. The
> > other piece, though, is recording enough information to be able to
> > pinpoint the problem.
> 
> It's not my job to design this thing for you, but I guess that's what
> I have to do to get you to think out of the box a little bit :-/

Uh, perhaps you missed the rest of the email, where I said I'm thinking of
a couple of approaches. The purpose of the email was to let you know briefly
that I am looking at approaches that will meet your 16-bit space constraint.

> Maintain a table, which is only recorded into when the debugging
> feature is enable (via sysctl or whatever) which remembers this stuff.
> 
> That way nobody eats the space or time overhead unless the debugging
> feature is enabled.

Your description is general enough that I may misunderstand your idea,
but it sounds like, if debugging was on, you'd be recording every call to
alloc_skb and kfree_skb in your table. This would use a lot of memory.
You can't simply have a circular list, because an sk_buff might be allocated
for a very long time before being used and you would overwrite its entry.
This would reduce the reliability of the information, which is the last thing
you want in a debugging tool. So, I'm considering approaches without this
drawback.

> Wow, I had to use every brain cell I have to come up with that one!

David VomLehn

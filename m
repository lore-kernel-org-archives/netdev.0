From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Why linux keeps connected routes when link goes down
Date: Mon, 23 Feb 2009 16:14:11 -0500
Message-ID: <20090223211411.GI23244@csclub.uwaterloo.ca>
References: <200902190203.41497.homecreate@list.ru> <20090220.121508.252047266.davem@davemloft.net> <20090223143830.GA23244@csclub.uwaterloo.ca> <200902232302.56819.homecreate@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: ???????????? ???????????????????? <homecreate@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:52962 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751010AbZBWVON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 16:14:13 -0500
Content-Disposition: inline
In-Reply-To: <200902232302.56819.homecreate@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2009 at 11:02:55PM +0500, ???????????? ???????????????????? wrote:
> Can I hope that it will be done some day?

I don't have much hope that the kernel will ever be changed to behave
as desired for a router.

> Linux is used as router in many places, such behavior is a suicide. Of course, 
> one can use ifplugd (so do I), but it's a crap for network OS, don't you think 
> so?

Well you will need some user space support to handle static routes,
unless you want to make major changes to the kernel route management.
We use zebra to manage static routes when the link goes up or down, with
the kernel simply patched to delete the subnet route when an interface
goes down, and re add it when it comes back up.  All other routes are
handled by zebra.

With the current patch I am using all routes assigned to an interface goes
away when the link goes down, but the kernel only recreates the directly
connected network's route when it comes up.  Any other static routes
have to be recreated by user space, hence the user of zebra for that.

Better and more friendly would be if routes could be marked inactive
and ignored by the kernel for routing decisions when a link went down.
That way multiple routes with different metrics could be used with the
best one who's link is up would be in use.  I find this too much to try
and put into the kernel though, so I will stick to zebra for that task.

> Who made linux network subsystem? Can Linus Torvalds say some words about this 
> problem?
> 
> I'm not a developer, but network administrator. So I can't make a patch. I can 
> only find a solution or make it. So please make my work a bit easier

-- 
Len Sorensen

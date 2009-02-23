From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Why linux keeps connected routes when link goes down
Date: Mon, 23 Feb 2009 13:38:15 -0800
Message-ID: <20090223133815.6acd817d@extreme>
References: <200902190203.41497.homecreate@list.ru>
	<20090220.121508.252047266.davem@davemloft.net>
	<20090223143830.GA23244@csclub.uwaterloo.ca>
	<200902232302.56819.homecreate@list.ru>
	<20090223211411.GI23244@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ???????????? ???????????????????? <homecreate@list.ru>,
	netdev@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45152 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600AbZBWViT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 16:38:19 -0500
In-Reply-To: <20090223211411.GI23244@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Feb 2009 16:14:11 -0500
lsorense@csclub.uwaterloo.ca (Lennart Sorensen) wrote:

> On Mon, Feb 23, 2009 at 11:02:55PM +0500, ???????????? ???????????????????? wrote:
> > Can I hope that it will be done some day?
> 
> I don't have much hope that the kernel will ever be changed to behave
> as desired for a router.
> 
> > Linux is used as router in many places, such behavior is a suicide. Of course, 
> > one can use ifplugd (so do I), but it's a crap for network OS, don't you think 
> > so?
> 
> Well you will need some user space support to handle static routes,
> unless you want to make major changes to the kernel route management.
> We use zebra to manage static routes when the link goes up or down, with
> the kernel simply patched to delete the subnet route when an interface
> goes down, and re add it when it comes back up.  All other routes are
> handled by zebra.
> 
> With the current patch I am using all routes assigned to an interface goes
> away when the link goes down, but the kernel only recreates the directly
> connected network's route when it comes up.  Any other static routes
> have to be recreated by user space, hence the user of zebra for that.
> 
> Better and more friendly would be if routes could be marked inactive
> and ignored by the kernel for routing decisions when a link went down.
> That way multiple routes with different metrics could be used with the
> best one who's link is up would be in use.  I find this too much to try
> and put into the kernel though, so I will stick to zebra for that task.
> 
> > Who made linux network subsystem? Can Linus Torvalds say some words about this 
> > problem?
> > 
> > I'm not a developer, but network administrator. So I can't make a patch. I can 
> > only find a solution or make it. So please make my work a bit easier
> 

Like I said already, it is possible to fix Quagga; we have done it the
patches are available. unfortunately quagga is without a real
software maintenance infrastructure at this point.

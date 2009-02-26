From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: unloading the ipv6 module
Date: Thu, 26 Feb 2009 12:22:33 -0800
Message-ID: <20090226122233.3d53bba7@nehalam>
References: <49A69784.6070204@free.fr>
	<20090226.052411.77955912.davem@davemloft.net>
	<20090226180920.GO28512@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, daniel.lezcano@free.fr,
	netdev@vger.kernel.org
To: Matti Aarnio <matti.aarnio@zmailer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51522 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753029AbZBZUWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:22:37 -0500
In-Reply-To: <20090226180920.GO28512@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2009 20:09:20 +0200
Matti Aarnio <matti.aarnio@zmailer.org> wrote:

> On Thu, Feb 26, 2009 at 05:24:11AM -0800, David Miller wrote:
> > From: Daniel Lezcano <daniel.lezcano@free.fr>
> > Date: Thu, 26 Feb 2009 14:22:12 +0100
> > 
> > > I saw in net/ipv6/Kconfig a comment saying
> > > "IPv6 as module will cause a CRASH if you try to unload it".
> > > 
> > > If I refer to this comment, that means unloading of ipv6 is not
> > > supported (which makes sense), will it be one day supported?
> > 
> > It's very unlikely to be supported any time soon.
> > 
> > Maybe "one day" as in 5 years from now at the earliest.
> 
> My guess is that somebody reasonably proficient coder with
> a week of free time can get it to unload properly.
> 
> I did it once in 2.4 days, I recall..  Not completely, but mostly.
> 
> > It's just such an enormous set of problems to solve to make it work,
> > and there are so many more urgent issues to work on.
> 
> Like refactoring the system to have IPv4 specific codes,
> IPv6 specific codes, and common codes...   But DaveM has
> probably other items in mind.
> 

The issue is the reference counting. IPV6 has some internal sockets
that stay open and hold therefore hold references to itself.
These reference counts must be accounted for and managed properly.

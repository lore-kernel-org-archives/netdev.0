From: Andi Kleen <andi@firstfloor.org>
Subject: Re: a maze of twisty stats, most different
Date: Fri, 29 Jun 2007 21:37:42 +0200
Message-ID: <20070629193742.GA31569@one.firstfloor.org>
References: <p73abui4qj4.fsf@bingen.suse.de> <OFAD87D0AB.C0688B5F-ON88257309.006374DE-88257309.0064D4D0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, ak@suse.de,
	Chris Snook <csnook@redhat.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Rick Jones <rick.jones2@hp.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50648 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbXF2Thq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 15:37:46 -0400
Content-Disposition: inline
In-Reply-To: <OFAD87D0AB.C0688B5F-ON88257309.006374DE-88257309.0064D4D0@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> That works ok for some things, like new global counters, but some
> items really fit best in existing files and the concern there is about
> other uses of them beyond the standard tools.
>         Examples:
> -addition of route age in /proc/net/route and /proc/net/ipv6_route

Routing information belongs into netlink imho. The /proc setup
for it already only shows a small subset of it. Netlink is easily
extensible -- just add new headers.

> -per-group data in /proc/net/igmp & igmp6

Don't know.  But you can probably just add more fields there,
multicasting is not exactly something that a lot of people care about
so there are likely not many scripts that might get broken.

> -per-interface MLD MIB info, which ought to go with other per-interface 
> data

ethtool ?  It's also extensible, although you have to change
the userland. But I don't think there is a risk of someone's script
breaking.

> 
>         I think everything that uses this kind of interface ought to do
> label matching, so additional columns in a row (anywhere in the row)
> would just be skipped/ignored by things that don't understand them,
> and similarlarly for single-row tagged items. You can do that in scripts
> with awk, but if existing items don't, they'll break.

I would expect shell scripts to generally do netstat -s | ..., which
is easily matchable.


-Andi> 
> 

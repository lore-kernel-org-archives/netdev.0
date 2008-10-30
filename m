From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] HTB updates class's bstats in one place
Date: Thu, 30 Oct 2008 08:11:58 +0100
Message-ID: <49095E3E.70705@trash.net>
References: <20081029102356.GA6165@ff.dom.local> <49083BF5.5090606@trash.net> <412e6f7f0810291803j3858cd2fq373a9c4f49664825@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53099 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbYJ3HME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 03:12:04 -0400
In-Reply-To: <412e6f7f0810291803j3858cd2fq373a9c4f49664825@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Wed, Oct 29, 2008 at 6:33 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Only for purely informational purposes, for policing you'd want to
>> use arrival rates. Since there are no users of estimators in the kernel
>> besides policers (which use seperate ones), the point is not terribly
>> important.
> 
> Where can I find sth. about this?
> 
> In fact, this bug is encountered when I am trying to implement a
> statistic daemon in user space. It fetches the classes's statistics
> data periodicity, then calculates the rate based on the data fetched.
> In some cases, it reports the leaf classes's rate is over theirs
> limit, but its ascent's isn't.
> 
> I think there must be someone does the same thing as me. So the
> feature is important for them too. If we don't fix it, how can I
> archive my requirement? Any comment?

Independant of this statistics bug, according to your description
you want to measure departure rates (otherwise the measured rates
can't really be compared to the limit) and the current counters are
not really suitable for this since they count arriving packets.
So the only way to properly do this is to add seperate counters that
account for departing packets. I think this would be a good addition
since we've always been advocating to do this stuff in userspace,
but it would need some thought on how to minimize the impact for
people not needing it.


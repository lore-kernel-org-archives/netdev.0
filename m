From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] genetlink: make netns aware
Date: Wed, 17 Jun 2009 14:49:30 -0700
Message-ID: <m1hbyev8d1.fsf@fess.ebiederm.org>
References: <1245267218.31588.41.camel@johannes.local>
	<m18wjqwoca.fsf@fess.ebiederm.org>
	<1245274620.31588.49.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47791 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbZFQVtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 17:49:32 -0400
In-Reply-To: <1245274620.31588.49.camel@johannes.local> (Johannes Berg's message of "Wed\, 17 Jun 2009 23\:37\:00 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Wed, 2009-06-17 at 14:19 -0700, Eric W. Biederman wrote:
>
>> Nothing at first glance looks wrong.
>
> Will review locking :) Not sure I hold enough locks at the correct
> places here.

grr. At first glance NOTHING looks wrong.
I have a bad habit of skipping the most important word in my sentences
sometimes.

>> Most of these genetlink things are network related so making it
>> network namespace aware makes sense.
>
> Well, some are non-network, and some are network, like nl80211. My goal
> is this patch:
> http://johannes.sipsolutions.net/patches/kernel/all/LATEST/016-cfg80211-netns.patch
>
> It already kinda works, but has bugs like not going back to init_net if
> the ns a wiphy is in exits, and some more like that.
>
>> My impression had been that genetlink was mostly not network related
>> and I would have to solve the other hard problem of how to filter
>> sockets based on other namespaces.  I guess that can be delayed for
>> a while longer.
>
> Ah, well, I was thinking that the generic netlink family code would have
> to take care of that.

Probably.  As even genetlink has those kinds of users.  The kernel
receive path is easy now.  Yeah for synchronous processing. It is
which socket do you transmit on that is interesting.

Eric

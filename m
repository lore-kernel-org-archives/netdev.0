From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] skbuff: Add new tc classify variable
Date: Wed, 8 Feb 2012 09:54:49 +0100
Message-ID: <20120208085449.GA14772@Chamillionaire.breakpoint.cc>
References: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
 <20120207110522.70663963@nehalam.linuxnetplumber.net>
 <20120207195729.GA26533@pandem0nium>
 <20120207134553.220a1da5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:34599 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756556Ab2BHIyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 03:54:52 -0500
Content-Disposition: inline
In-Reply-To: <20120207134553.220a1da5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:
> > On Tue, Feb 07, 2012 at 11:05:22AM -0800, Stephen Hemminger wrote:
> > > On Tue,  7 Feb 2012 19:39:08 +0100
> > > Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de> wrote:
> > > 
> > > I don't understand why this is better, we already have mark to do this.
> > > Your method saves adding a tc filter to map mark to classid, but that is hardly
> > > a huge burden.
> > 
> > Unfortunately, it is. We have previously built our trees by setting marks with iptables
> > and matching the masks with tc and the u32 matcher, but we got a rather big performance
> > impact as soon as the number of users grow. The target platform are WiFi access points.
> > By using the proposed patch, the performance stays nearly constant at a growing number
> > of users.
> 
> The problem then is not the use of marks but having to add a filter rule for
> each mark. We need something like u32 hash but for marks to build a table
> of mark -> class id.  The current method uses a linear list of filter rules,
> which is an obvious bottleneck with lots of classes.

Maybe.  But marks might already be used e.g. for policy routing or for
additional metadata (such as encoding higher level data).

And even if you do your 'mark identifies the traffic class' very late in
your iptables ruleset -- as soon as you've got tunnels configured,
the encapsulated packets end up travellign through the ruleset again
with a "classid mark" set -- which might interfere with the ruleset.

IOW, using -j CLASSIFY does have advantages regardless of the "tc mark filter"
performance issue Simon has.

There is also the SO_PRIORITY setsockopt which userspace might be using to pick a
particular traffic class...

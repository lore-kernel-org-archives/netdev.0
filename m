From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
 feature-negotiation patches
Date: Tue, 09 Sep 2008 01:57:20 -0700 (PDT)
Message-ID: <20080909.015720.204027435.davem@davemloft.net>
References: <20080904061511.GA30756@gerrit.erg.abdn.ac.uk>
	<20080908.173250.204419507.davem@davemloft.net>
	<20080909080911.GA9176@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60514
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753951AbYIII51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 04:57:27 -0400
In-Reply-To: <20080909080911.GA9176@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 9 Sep 2008 10:09:11 +0200

> | > This is an update with regard to Wei's comments. I have re-synched 
> | > 
> | > 	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree `dccp']
> | > 	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=shortlog;h=dccp
> | > 
> | > Also did some testing with a client that only supports CCID 2/3 talking to a client supporting
> | > CCID 2/3/4. They could still negotiate and settle for a common CCID.
> | 
> Sorry the above includes the whole dccp test tree, over and above the
> feature negotiation. We have been waiting for Arnaldo and there was a
> phase where people sent comments about this patch set, so I had not
> prepared a second net-next-2.6 pull request for this patch set yet.
> 
> If you want to revert this, I will prepare a net-next-2.6 clone with
> just the revised 37 patches from this set.
> 
> Otherwise some parts (as below) need to be modified.

Just send me whatever fixup patches are needed as another pull request.

I realize your time is limited, but SO IS MINE, and this bogon GIT
tree you asked me to pull from is just one in a long line of time
consuming exercises you've put me through ever since taking over DCCP
maintainence.

And when you crap up net-next-2.6 you effect other people doing
networking work too, not just me and you.  You also effect everyone
trying to test the -next tree since net-next-2.6 gets sucked into
there every day.

You can't seem to get the whole review process right, yet it's the
most important aspect of getting changes into the tree.  It's 1,000
times more important that implementing the code in the first place.

For starters, you don't dump 30 or 40 patches on people's laps for
review.  You give them 5, maybe 10, at a time.  And you submit them
when you write them, so that you don't have to rewrite everything
after the ones that need fixups.

And once you've submitted a large chunk of changes like you did this
time, you've worn out your reviewer pool, and they'll need a long
recovery period before they can devote time to looking at this stuff
again.

> | Don't warn about crap like this, instead convert the code over to hrtimers.
> | 
> | This kernel being built, even with HZ=100, can do nanosecond timers on
> | my systems, but that's only if you would make proper use of them.
> | 
> The present sk_timer implementation uses the algorithm from RFC 3448. I
> did not want to blindly port it to hrtimer since so far the following
> difficulties were in the way:
> 
>  * when using the algorithm from RFC 3448, 4.6 directly with hrtimers,
>    a large burst of activity will result, especially on fast links;
> 
>  * I have doubts whether it will help: each time the precision is improved,
>    more frantic high-frequency noise results in CCID-3:

To me this is just pure bullshit, I'm sorry to say.

A warning gets added that barks at the person compiling this stuff
saying: "YOUR TIMER ISN'T ACCURATE ENOUGH" and now you're telling me
your concerned that hrtimers might give too much accuracy.

Which is it?

Lower limit the hrtimer interval, or make it as course as you damn
well need, anything but this pile of excuses.

HZ=100 is extremely common, and there is no reason to bark at people
about something they can do absolutely nothing about.  Who in the
world is supposed to act upon that warning?

Yet now everyone building the linux -next tree will see it if their HZ
is choosen to be low enough and we'll thus get piles of "what's this?"
queries on all the lists.

Look...

This whole process isn't going smoothly.  You are time limited, and
the place you are short changing, time wise, appears to be the whole
submission and review process.  Yet this should be your highest
priority, far and above implementing even one single line of code.

Now net-next-2.6 is crapped up with an unintentional DCCP pull.  And I
pushed it out, so I can't just revert this junk, other people use
net-next-2.6 as their development base.  So if I rebase it, I screw up
their work.

I totally trusted you, fixed up the merge errors, and figured you
really must have meant to send me all of that stuff.

This is what happens when you try to manage a huge chunk of changes that
needed review, all at once.

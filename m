From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 14:35:56 -0700 (PDT)
Message-ID: <20080819.143556.245692295.davem@davemloft.net>
References: <20080819.140458.236030589.davem@davemloft.net>
	<200808192315.48718.rjw@sisk.pl>
	<alpine.LFD.1.10.0808191425050.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53832
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753087AbYHSVf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 17:35:56 -0400
In-Reply-To: <alpine.LFD.1.10.0808191425050.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 19 Aug 2008 14:28:49 -0700 (PDT)

> Yeah, and the real cause was apparently another commit that *ALSO* 
> happened after the merge window!
> 
> Guys, you're making excuses for the problem.
> 
> The problem that triggered this bugus loopback change was commit 
> e5a4a72d4f88f4389e9340d383ca67031d1b8536. Look at when that one was done. 
> 
> This is my whole _point_. The networking layer is doing development during 
> the -rc window. And you guys are making excuses for it. Wake up, guys!

That change was made under the pretext that it was tested heavily and
that if we hit any problem whatsoever with it that we couldn't fix
quickly it would be reverted.

If you look at the pull request I sent you that contained that change,
I pointed this change out as "highlight" and explained the situation,
in detail.  Here it is:

	4) Lennert Buytenhek did some really nice analysis on a network
	   device that cannot do TSO offloading in hardware.  He checked
	   out what happens if you enable the software TSO mechanism fallback
	   we have in the kernel, and it improves CPU utilization tremendously.

	   It is safe to do this as long as the device in question can
	   support scatter-gather.

	   Herbert and I are discussing a way to do this even more efficiently
	   with some help from the device (currently the code has to allocate
	   extra sk_buff objects as we split up the TSO frame, and then do
	   a bunch of extra page ref counting, when all we need is some headers
	   and some way to say where the data portion split points are).

	   If this causes any problems whatsoever, it's trivial to revert this.

Did you read it?  I write those for you specifically, so that you know
what changes in there are "of note" and you may want to be aware of.

But anyways, let's chalk this one up as inappropriate.

Looking through the rest of the networking changes in this
pull I see real bug fixes in all of the netxen and e1000
changes that seemed to stand out.  All of the wireless stuff
looks like real bug fixes for things reported by real users.

And then there are 2 or 3 cleanups that probably could have
waited.

And then there is the Bluetooth SCO change which I agree was
borderline and I should have pushed back on.

There are simply a lot of people fixing a lot of bugs.  And I have to
stay on top of it all.  And I also have to be able to trust John
Linville, Jeff Garzik, Marcel, and others so that I don't have to be
checking up on them every single time.  I look at what they send me,
and I do push back when I see obviously bogus stuff, but there is a
trust breakpoint.

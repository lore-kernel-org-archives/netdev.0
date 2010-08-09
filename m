From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Mon, 9 Aug 2010 13:34:29 -0400
Message-ID: <20100809173429.GR30010@kvack.org>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org> <20091029233848.GV3141@kvack.org> <4C603999.1030801@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:51667 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784Ab0HIR6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Aug 2010 13:58:01 -0400
Content-Disposition: inline
In-Reply-To: <4C603999.1030801@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben,

On Mon, Aug 09, 2010 at 10:23:37AM -0700, Ben Greear wrote:
> I was just comparing my out-of-tree patch set to .35, and it appears
> little or none of the patches discussed in this thread are in the
> upstream kernel yet.

I was waiting on Eric's sysfs changes for namespaces to settle down, but 
ended up getting busy on other things.  I guess now is a good time to pick 
this back up and try to merge my changes for improving interface scaling.  
I'll send out a new version of the patches sometime in the next couple of 
days.  I'm also about to make a new Babylon release as well, I just need 
to write some more documentation. :-/

Btw, one thing I noticed but haven't been able to come up with a fix for 
yet is that iptables has scaling issues with lots of interfaces.  
Specifically, we had to start adding one iptables rule per interface for smtp 
filtering (not all subscribers are permitted to send smtp directly out to 
the net, so it has to be per-interface).  It seems that those all get 
dumped into a giant list.  What I'd like to do is to be able to attach rules 
directly to the interface, but I haven't really had the time to do a mergable 
set of changes for that.  Thoughts anyone?

		-ben

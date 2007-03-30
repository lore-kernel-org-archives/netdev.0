From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: tcp crash in net-2.6 tree
Date: Fri, 30 Mar 2007 15:06:03 -0700
Message-ID: <20070330150603.edeb2023.akpm@linux-foundation.org>
References: <20070329230917.63c3f79c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703301618510.23854@kivilampi-30.cs.helsinki.fi>
	<20070330.144347.68157619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:54686 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932185AbXC3WGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 18:06:33 -0400
In-Reply-To: <20070330.144347.68157619.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Mar 2007 14:43:47 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: "Ilpo_J__rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Fri, 30 Mar 2007 17:33:28 +0300 (EEST)
> 
> > If there is nothing at high_seq (application hasn't given any data to/past 
> > that point), the search fails to find any skb and returns NULL... But I 
> > have no idea how this can happen? As TCP does after(skb->seq, 
> > tp->high_seq) (even in the quoted code block) guaranteeing that something 
> > is there after the high_seq for TCP to step temporarily on... So at least 
> > one skb should have it's end_seq after tp->high_seq (actually there 
> > should be at least two valid skbs after tp->high_seq since the used 
> > sequence number space does not have holes), which should be enough to get 
> > an existing skb from write_queue_find?!
> > 
> > I also checked all call paths to tcp_update_scoreboard_fack to make sure 
> > that snd_una hasn't gone past high_seq and found nothing suspicious (and 
> > that wouldn't return NULL anyway I think)...
> 
> Let's not speculate, let's find out for sure if snd_una is
> surpassing high_seq while we're in this state.
> 
> Andrew please give this debugging patch a spin,

OK, will take a look at that this evening, hopefully.

> and also what
> is your workload?  I'd like to play with it too.

I use an x86_64 box as a distcc server: shove .i fiels at it, get .o files
sent back.  I was using it thusly and noticed that it had died.

Also, an x86_64 box I have here at google was hanging yesterday and that
appears to have stopped since I removed a couple of x86_64 patches and
git-net.  I'm in the process of working out what fixed it...


> I've tried to code this patch so that if the bug triggers your
> machine shouldn't crash and burn completely, just spit out the
> log message.

ok..  I don't know how repeatable the distcc crash is.  We'll see.

distccd seems to be rather good at triggering networking problems - I think
that's the third one I've seen in the past few years.



From: Andres Freund <andres@anarazel.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 ( possibly?caused by netem)
Date: Mon, 6 Jul 2009 18:13:29 +0200
Message-ID: <200907061813.29379.andres@anarazel.de>
References: <200907031326.21822.andres@anarazel.de> <a5d9929e0907052153x2db851bcj26f1433c716c8a90@mail.gmail.com> <20090706141916.GA3477@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.anarazel.de ([217.115.131.40]:40032 "EHLO smtp.anarazel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117AbZGFQN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 12:13:29 -0400
In-Reply-To: <20090706141916.GA3477@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 06 July 2009 16:19:16 Jarek Poplawski wrote:
> On Mon, Jul 06, 2009 at 05:53:51AM +0100, Joao Correia wrote:
> > Hello
> >
> > System freezes immediatly after grub, no init processing at all, after
> > applying those patches on top of vanilla 2.6.30 on my box.
>
> ...
>
> > doesnt work on top of 2.6.30. It complains, while compiling, that
> > sysctl_timer_migration is not defined. So i just replaced that call
> > with return 1, like on the not debug case. Hope this doesnt defeat
> > your test case, but it wouldnt compile otherwise. Probably that was
> > just introduced after 2.6.30?

I stupidly sent two emails in private to Jarek. Reposting here:

Jarek:
> > > > > Yes, my bad, sorry. I've found 2 more patches from this series; 
can't
> > > > > guarantee that's all, but seems to work & migrate within my one and
> > > > > only core without any problems ;-)
Andres:
> > > > I have some doubt that this will give us new information:
> > > > The commit i bisected the failure to:
> > > > eea08f32adb3f97553d49a4f79a119833036000a
> > > > Is just 2.6.30-rc4 + the four commits you listed...
Jarek:
> > > I guess, you mean 2.6.31-rc1?
Andres:
> > No - I tested the timer development branch to exclude its a problem caused
> > by some other change between 2.6.30 and 2.6.31-git
> > And that branch is based on rc4...
Jarek:
> I misunderstood, sorry! That's just what I needed to know!

Andres:
> > > > And I seperately tested eea08f32adb3f97553d49a4f79a119833036000a^ to
> > > > be sure. So I am pretty sure its those commits which trigger the
> > > > problem - whats causing it is another matter.
Jarek:
> > > It might be true, but it isn't 100% proof. This patchset is special:
> > > by moving timers to other cores it generates much more SMP concurrency,
> > > so it could trigger some hidden races, which otherwise need much more
> > > time to show up. So I'm trying to establish if this could be the case.
> > > Btw., I guess there is nothing to hide from the lists, plus somebody
> > > could verify this idea?
Andres:
> > No, absolutely not. Just hit the wrong key. Sorry.
> > Btw, I ran netem with delay for more than 48h on around 80mbit... That
> > does  not exclude such a rarely triggered race, but makes it a bit more
> > unlikely. (With migration thats around 3sec or so)
> This is a very important information: it should give timers' guys some
> incentive to start looking for this, and me less incentive to verify
> network code ;-)
Jarek:
> Btw., there were some strange traces of lockdep and stack overruning;
> did you try if without lockdep maybe there are some more readable
> warnings?
Lockdep was not enabled at first. Actually I think most if not all of the 
traces I posted at first were without.

Will verify.
> And once again, consider resending this to the public, please. (At
> least Joao might be interested.)
Sorry once more.


Andres

From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: BUG? locking issue(networking?) with latest git
Date: Thu, 4 Sep 2008 12:46:11 +0300
Message-ID: <200809041246.11255.denys@visp.net.lb>
References: <20080904072155.GA4691@ff.dom.local> <200809041203.07460.denys@visp.net.lb> <20080904093854.GA5407@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:45572 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbYIDJrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 05:47:31 -0400
In-Reply-To: <20080904093854.GA5407@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 September 2008, Jarek Poplawski wrote:
> On Thu, Sep 04, 2008 at 12:03:07PM +0300, Denys Fedoryshchenko wrote:
> > On Thursday 04 September 2008, Jarek Poplawski wrote:
> > > On 03-09-2008 13:22, Denys Fedoryshchenko wrote:
> > > > I am getting strange lockup, all operations (tc, ifconfig,pppd) after
> > > > few days running pppoe-server.
> > > >
> > > > Programgs getting blocked very strange way, i am not able to kill
> > > > them even. Softlockup detection enabled, lock dependencies (except
> > > > lock dependency engine debugging), RT mutexes and deadlock detection
> > > > enabled too.
> > > >
> > > > I notice this bug few weeks ago, even before latest patches, and
> > > > seems it still remains.
> > >
> > > Do you mean this didn't happen with some 2.6.27-rc's? (There was quite
> > > substantial change in ppp_generic with lock_kernel() in 2.6.27-rc1.)
> >
> > I was not able to run early rc's on my pppoe's. Do you suggest to try
> > reverse those changes?
>
> No, I don't think reverting them would be easy enough (except moving
> back to 2.6.26). I simply wonder if you think there were some
> 2.6.27-rc's tried by you, which didn't lockup like this.
There is sadly my shapers, which crashing on early rc's.

>
> > > Alas it shows only some tasks waiting for locks. Maybe it's enough for
> > > someone with better ppp knowledge, but unless there is such a response
> > > I guess you should better try with PROVE_LOCKING turned on yet.
> >
> > It is already turned on.
>
> So I misread this "except lock dependency engine debugging" part. OK,
> I'll try to think about it, but any additional logs should be helpful.
> BTW, I wonder if it's possible to test this without SMP?
Done, booted with nosmp flag. Till crash i need to wait 1-3 days.

I tried to check for any additional logs, but there is nothing seems.
Once i got softlockup for pppd, and server restarted. Other times it is just 
getting stuck on any network operations (ifconfig, pppd crashing in the 
middle, tc). I am not able to attach to processes by strace/gdb, so it is 
difficult to tell even on which point it does crash.
>
> Jarek P.



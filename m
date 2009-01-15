From: Chris Caputo <ccaputo@alt.net>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 12:00:50 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.0901151139440.20461@nacho.alt.net>
References: <20081010090426.GA6054@ff.dom.local>
	<Pine.LNX.4.64.0901110438050.16453@nacho.alt.net>
	<20090114063909.GA4234@ff.dom.local>
	<200901141417.58667.denys@visp.net.lb>
	<1231937404.14825.4.camel@laptop>
	<Pine.LNX.4.64.0901141748300.17915@nacho.alt.net>
	<20090115065322.GA4190@ff.dom.local>
	<Pine.LNX.4.64.0901150724000.20461@nacho.alt.net>
	<20090115075450.GB4190@ff.dom.local>
	<20090115094530.GG4190@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Jarek Poplawski <jarkao2@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nacho.alt.net ([208.90.169.18]:33629 "EHLO nacho.alt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759901AbZAOMHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 07:07:33 -0500
In-Reply-To: <20090115094530.GG4190@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jan 2009, Jarek Poplawski wrote:
> On Thu, Jan 15, 2009 at 07:54:50AM +0000, Jarek Poplawski wrote:
> > On Thu, Jan 15, 2009 at 07:26:28AM +0000, Chris Caputo wrote:
> > > On Thu, 15 Jan 2009, Jarek Poplawski wrote:
> > > > On Wed, Jan 14, 2009 at 06:02:04PM +0000, Chris Caputo wrote:
> > > > ...
> > > > > That said, I would not recommend just the three for -stable unless they 
> > > > > get a much wider amount of testing, on multiple platforms.  I don't see 
> > > > > that as likely to happen, plus Peter says they are incomplete, so maybe it 
> > > > > is just best to recommend that 2.6.28 users getting crashes while using 
> > > > > HTB try these specific patches at first, and then the rest of the patches 
> > > > > if they do not work.
> > ...
> > > I hope you can forgive me, but since I have something that works on a 
> > > production machine, I am not in a position in which I can test this.
> > 
> > So, IOW, you don't recommend Peter's patches but prefere to use them,
> > and recommend my patches, but you are afraid of using them...
> 
> Sorry, Chris! It looks like I misunderstood, and you recomend Peter's
> patches yet. (But I guess there are users relying on official kernel
> versions.)
> 
> I hope you can forgive me,

:-)  No worries.

Just to be clear, by "these specific patches at first", I mean the 
"hrtimer: removing all ur callback modes" ones:

 ca109491f612aab5c8152207631c0444f63da97f
 37810659ea7d9572c5ac284ade272f806ef8f788
 a0a99b227da57f81319dd239bc4de811b0f530ec

By "rest of the patches", I mean the above plus the others created by
Peter for hrtimers.  Full list:

 ca109491f612aab5c8152207631c0444f63da97f
 37810659ea7d9572c5ac284ade272f806ef8f788
 a0a99b227da57f81319dd239bc4de811b0f530ec
 b2e3c0adec918ea22b6c9d7c76193dd3aaba9bd4
 8bdec955b0da2ffbd10eb9b200651dd1f9e366f2
 d5fd43c4ae04523e1dcd7794f9c511b289851350
 731a55ba0f17064f85903b7bf8e24849ec6cfa20
 a6037b61c2f5fc99c57c15b26d7cfa58bbb34008
 e3f1d883740b09e5116d4d4e30a6a6987264a83c
 82c5b7b527ccc4b5d3cf832437e842f9d2920a79
 6e5c172cf7ca1ab878cc6a6a4c1d52fef60f3ee0

The first 3 git patches listed above are working for me so far, so I have 
not had a need to try the others.

On Thu, Jan 15, 2009 at 11:57:13AM +0200, Denys Fedoryschenko wrote:
> I didn't notice a bug, just because all that time i was using it without
> hrtimers (because of nmi_watchdog).

nmi_watchdog 1 or 2?  I'm running with 2 which I've read does not disable 
hrtimers, right?

I mention it because my original HTB/hrtimers-related crash on .28 was 
without nmi_watchdog altogether.  I added both "nmi_watchdog=panic,2" and 
Peter's first 3 patches (ca1, 378, a0a) at the same time, to produce an 
apparently stable system.

I wish I had a repro scenario in a non-production environment, so I could 
help out further with this.  If I did, I would test without nmi_watchdog 
while trying just 2.6.28 and Jarek's #4 patch.

Chris

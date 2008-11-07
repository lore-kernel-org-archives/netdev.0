From: Sven-Thorsten Dietrich <sven@thebigcorporation.com>
Subject: Re: Network performance forwarding tests on RT
Date: Fri, 07 Nov 2008 13:22:43 -0800
Message-ID: <1226092963.5685.14.camel@dd>
References: <20081105115205.14c5282f@s6510>
	 <20081106185029.0d4c5cd8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	linux-rt-users@vger.kernel.org, netdev@vger.kernel.org
To: Clark Williams <williams@redhat.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20081106185029.0d4c5cd8@redhat.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-11-06 at 18:50 -0600, Clark Williams wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On Wed, 5 Nov 2008 11:52:05 -0800
> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
> > As an experiment, I rebuilt a version of Vyatta using 2.6.26-rt11 kernel.
> > This required some fixes to unionfs and aufs which I'll send to anyone who wants.
> 
> I'd like to see those fixes.

I have seen the same issues, and I think I had a patch for these laying
around - I'll defer to Stephen for his version.

> 
> > 
> > The performance of the RT PREEMPT kernel is worse than non-PREEMPT kernel.
> > 
> > Running RFC2544, frame loss test we the loss rate is worse on RT than non RT.
> > Ideally, there would be no loss, but on this platform, the best we have
> > seen is 70% loss at 64 bytes.
> > 
> 
> We've seen that as you push the workloads up to max, the additional overhead of rt_mutexes starts to show and the performance of the RT kernel drops off.  So if you're trying to push the maximum amount of bits across a wire and you don't care about event latency, then I wouldn't recommend an RT kernel. 
> 
> > 
> > Size	2.6.26		2.6.26-rt11
> > 64	80.5%		99%
> > 128	67		99
> > 256	43		92
> > 512	0		54
> > 1024	0		3
> > 1280	0		0
> > 1518	0		0
> > 
> > More importantly, with RT PREEMPT, the driver gets stuck and times out
> > under heavy load (see 99% loss above). It appears the change to network
> > scheduling related to NAPI doesn't work well under load.
> > 
> 
> Did you do anything with the priorities of interrupt threads? We generally boost hard IRQ threads (show up as [IRQ-xxx] in a ps) to SCHED_FIFO 80-85 and boost the softirq threads to between 70-75.
> 
> Since interrupt processing in RT takes place in SCHED_FIFO kernel threads, if you push the load up high enough, it's entirely possible to starve lower priority softirq/hardirq threads in the system.

ON SMP, you can also affinitize the threads on different CPUs. 

Check out Cset on the RT Wiki.

Sven

>  
> Clark
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v2.0.9 (GNU/Linux)
> 
> iEYEARECAAYFAkkTkNsACgkQHyuj/+TTEp1/oACdGj3cEsNTFD3zG1uXrJSnORx8
> 1RkAoKYAPCAQ4ALi5NPRMNbEE6CjkZQj
> =kO9h
> -----END PGP SIGNATURE-----
> NrybXv^){.n+{z"^nrzh&Gh(j"mzfh~m


From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Fri, 12 Sep 2008 13:16:19 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux> <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
 <20080826141812.589848a0@tux> <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
 <20080828184919.611dd578@tux> <Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
 <20080830035650.42be37d7@tux> <Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi>
 <20080907051718.58bf133d@tux> <Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
 <20080908172043.0d25a427@tux> <Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi>
 <20080911143006.2f516569@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1650166014-1221158589=:26799"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080911143006.2f516569@tux>
Content-ID: <Pine.LNX.4.64.0809121303340.1034@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1650166014-1221158589=:26799
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0809121303341.1034@wrl-59.cs.helsinki.fi>

On Thu, 11 Sep 2008, Dâniel Fraga wrote:

> On Thu, 11 Sep 2008 16:44:20 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > ...I guess it would be possible to remove SCHED_FEAT_HRTICK from
> > /proc/sys/kernel/sched_features then while keeping the hrtimers
> > otherwise enabled to test this.
> > 
> > It's possible that hrtimers just affect on how easy it is to trigger
> > but at least it seems an useful lead until proven otherwise.
> 
> 	You're right Ilpo. After days and days without the problem,
> today it triggered (but I wasn't online at the time, so I couldn't grab
> any data).

Thanks. Once we know what the userspace at the server is doing, it might 
make the problem immediately obvious, though I'm a bit afraid that e.g., 
strace might interfere with the problem so that it resolves right away and 
we're again left with nothing...

> 	So, you're correct. HRtimers just affect on how easy it is to
> trigger the issue. In other words: with high resolution timer enabled,
> the problem appears more frequently.
> 
> 	At least if we discovered a way how to trigger this, we could
> test it more easily. The problem is to wait a long time for it to
> happen.
> 
> 	Just a curiosity: on your servers,

I don't really have any I would call "server" in the sense you mean, I 
might occassionally set up one for test from time to time for a very 
limited period but normally it's just ssh and some other which I use so 
rarely that I'd hardly notice, and that's it. I was planning, however,
to setup some day a distcc stress test using all my spare cpu cycles 
(I'd like to put it under kvm but that got stalled due to some timing 
issue at the guest making it to go into an infinite loop), once I get
that working I could probably easily put other test-only stuff to that 
framework as well.

But but, there are other people around the world besides us :-), and 
afaict this is the only (outstanding) report which relates to ceasing of 
accept() so I doubt it's something very regularly occuring thing or we 
would have heard of it.

> do you use x86_64?

At least on some machines, but like you have discovered it seems to 
service dependant, so that some processes never got stuck, I might only 
run such or so, who knows...

> It seems
> this problem is very specific to x86_64 or appear more often on x86_64
> than x86_32. It never happens on my x86_32 bit servers.

Ok.

-- 
 i.
---696208474-1650166014-1221158589=:26799--

From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 11:40:16 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810311119510.7072@wrl-59.cs.helsinki.fi>
References: <20081026122300.GA30905@ioremap.net> <20081030111526.7d9bb0f8@extreme>
 <Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi>
 <20081031.005219.141937694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-739433781-1225446016=:7072"
Cc: shemminger@vyatta.com, zbr@ioremap.net, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35253 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbYJaJkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 05:40:19 -0400
In-Reply-To: <20081031.005219.141937694.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-739433781-1225446016=:7072
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 31 Oct 2008, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 30 Oct 2008 21:01:19 +0200 (EET)
> 
> > On Thu, 30 Oct 2008, Stephen Hemminger wrote:
> > 
> > > Has anyone looked into the impact of port randomization on this benchmark.
> > > If it is generating lots of sockets quickly there could be an impact:
> > >   * port randomization causes available port space to get filled non-uniformly
> > >     and what was once a linear scan may have to walk over existing ports.
> > >     (This could be improved by a hint bitmap)
> > > 
> > >   * port randomization adds at least one modulus operation per socket
> > >     creation. This could be optimized by using a loop instead.
> > 
> > I did something with AIM9's tcp_test recently (1-2 days ago depending on 
> > how one calculates that so didn't yet have time summarize the details in 
> > the AIM9 thread) by deterministicly binding in userspace and got much more 
> > sensible numbers than with randomized ports (2-4%/5-7% vs 25% variation 
> > some difference in variation in different kernel versions even with 
> > deterministic binding). Also, I'm still to actually oprofile and bisect 
> > the remaining ~4% regression (around 20% was reported by Christoph). For 
> > oprofiling I might have to change aim9 to do predefined number of loops 
> > instead of a deadline to get more consistent view on changes in per func 
> > runtime.
> 
> Yes, it looks like port selection cache and locking effects are
> a very real issue.
> 
> Good find.

Let me remind that it is just a single process, so no ping-pong & other 
lock related cache effects should play any significant role here, no? (I'm 
no expert though :-)).

One thing I didn't mention earlier, is that I also turned on 
tcp_tw_recycle to get the binding to work without giving
-ESOMETHING very early (also did some, possibly meaningless
things, like drop_caches before each test run, might be
significant only because of the test harness cause minor
variantions). I intend to try w/o binding of the client end
but I guess I might again get more variation between different
test runs.

-- 
 i.
---696208474-739433781-1225446016=:7072--

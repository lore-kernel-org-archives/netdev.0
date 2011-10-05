From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: big picture UDP/IP performance question re 2.6.18  -> 2.6.32
Date: Wed, 05 Oct 2011 17:33:47 +0200
Message-ID: <1317828827.6766.37.camel@twins>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
	  <alpine.DEB.2.00.1110041358500.12199@router.home>
	 <1317820942.6766.26.camel@twins>
	 <alpine.DEB.2.00.1110050915160.30467@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: starlight@binnacle.cx, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>, Ingo Molnar <mingo@elte.hu>
To: Christoph Lameter <cl@gentwo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1110050915160.30467@router.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-10-05 at 09:26 -0500, Christoph Lameter wrote:
> 
> > Also, for latency, we've got ftrace and a latencytracer, provide traces
> > that illustrate your fail.
> 
> We would need a backport of both to a kernel version that works with
> reasonable latencies so that we can figure out what caused these
> regressions for this particular case. Disabling network and kernel
> features usually gives you better performance but there are a lot of
> things in the hot paths these days that can not be disabled.

Well can can also just take the status quo and use tools like ftrace and
perf to find out what your hot paths are and where you're spending time.

On -rt we use the (irq)latencytracer a _lot_ to find problems, a
detailed function trace of WTH the kernel thinks its doing helps a lot
with trying to fix it.

Things like cyclictest are also useful to find application level
latencies, it can trace the entire latency path if needed.

Kernel level profiles are also a great tool to find out where you're
spending your time.

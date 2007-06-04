From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: iperf: performance regression (was b44 driver problem?)
Date: Mon, 04 Jun 2007 21:26:18 +0200
Message-ID: <1180985178.4404.48.camel@chaos>
References: <20070525172431.60affaca@freepuppy>
	 <200705281944.05030.maxi@daemonizer.de> <1180380230.3657.3.camel@chaos>
	 <200706031826.06891.maxi@daemonizer.de> <1180939188.4404.5.camel@chaos>
	 <20070604090918.42386fbb@freepuppy> <1180974958.4404.24.camel@chaos>
	 <20070604095924.651d91c8@freepuppy> <1180978368.4404.29.camel@chaos>
	 <20070604105158.31ede1f5@freepuppy>  <1180983647.4404.38.camel@chaos>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1180983647.4404.38.camel@chaos>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-04 at 21:00 +0200, Thomas Gleixner wrote:
> > 
> > Yes, the following patch makes iperf work better than ever.
> > But are other broken applications going to have same problem.
> > Sounds like the old "who runs first" fork() problems.
> 
> Not really. The fork() "who runs first" problem is nowhere specified.
> 
> usleep(0) is well defined:
> 
> .... If the value of useconds is 0, then the call has no effect.
> 
> So the call into the kernel has been wrong for quite a time.
> 

Just for clarification: I'm not saying that we should break the (broken)
user space ABI. I'm going to work out a patch which prints out a warning
(limited number per boot) and emulating the old behavior by a call to
yield() along with an entry into (mis)feature-removal.txt.

	tglx

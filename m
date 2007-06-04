From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 04 Jun 2007 18:35:58 +0200
Message-ID: <1180974958.4404.24.camel@chaos>
References: <20070525172431.60affaca@freepuppy>
	 <200705281944.05030.maxi@daemonizer.de> <1180380230.3657.3.camel@chaos>
	 <200706031826.06891.maxi@daemonizer.de> <1180939188.4404.5.camel@chaos>
	 <20070604090918.42386fbb@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070604090918.42386fbb@freepuppy>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-04 at 09:09 -0700, Stephen Hemminger wrote:
> > > I did the test with an 2.6.22-rc3-git4 kernel and the p54 driver built 
> > > external as module. 
> > 
> > Can you look at iperf to figure out, whether it does some weird timer
> > stuff (high frequency interval timer or such) ? Either check the code or
> > strace it.
>
> It is the receiver doing a tight loop doing gettimeofday/recv calls.
> 
> 
> sendto(-1227715616, 0xc, 3085438964, 0, {...}, 3067249832) = 0
> gettimeofday({1180973726, 981615}, NULL) = 0
> gettimeofday({1180973726, 981751}, NULL) = 0
> futex(0x8055c64, 0x5 /* FUTEX_??? */, 1) = 1
> futex(0x8055c90, FUTEX_WAKE, 1) = 0
> recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
> gettimeofday({1180973726, 982754}, NULL) = 0
> recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
> gettimeofday({1180973726, 983790}, NULL) = 0

Well, gettimeofday() is not affected by the highres code, but

> nanosleep({0, 0}, NULL) = 0
> nanosleep({0, 0}, NULL) = 0

is. The nanosleep call with a relative timeout of 0 returns immediately
with highres enabled, while it sleeps at least until the next tick
arrives when highres is off. Are there more of those stupid sleeps in
the code ?

	tglx

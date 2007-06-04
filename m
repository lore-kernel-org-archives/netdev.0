From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 4 Jun 2007 09:09:18 -0700
Message-ID: <20070604090918.42386fbb@freepuppy>
References: <20070525172431.60affaca@freepuppy>
	<200705281944.05030.maxi@daemonizer.de>
	<1180380230.3657.3.camel@chaos>
	<200706031826.06891.maxi@daemonizer.de>
	<1180939188.4404.5.camel@chaos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1180939188.4404.5.camel@chaos>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 04 Jun 2007 08:39:48 +0200
Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org> wrote:

> On Sun, 2007-06-03 at 18:26 +0200, Maximilian Engelhardt wrote:
> > > Is there any other strange behavior of the high res enabled kernel than
> > > the b44 problem ?
> > 
> > I didn't notice anything in the past (as I wrote). But today I did some tests 
> > for an updated version of the p54 mac80211 wlan driver and I noticed exactly 
> > the same problem:
> > 
> > when booting with highres=off everything is fine.
> > But when I boot an highres enabled kernel and I do the iperf-test with the p54 
> > driver, my systems becomes unresponsive during the test. It seems to be 
> > exactly the same problem I have with the b44 driver.
> > So this might not be a bug in the b44 code but a bug somewhere in the linux 
> > networking code.
> > 
> > I did the test with an 2.6.22-rc3-git4 kernel and the p54 driver built 
> > external as module. 
> 
> Can you look at iperf to figure out, whether it does some weird timer
> stuff (high frequency interval timer or such) ? Either check the code or
> strace it.
> 
> 	tglx
> 
> 


It is the receiver doing a tight loop doing gettimeofday/recv calls.


sendto(-1227715616, 0xc, 3085438964, 0, {...}, 3067249832) = 0
gettimeofday({1180973726, 981615}, NULL) = 0
gettimeofday({1180973726, 981751}, NULL) = 0
futex(0x8055c64, 0x5 /* FUTEX_??? */, 1) = 1
futex(0x8055c90, FUTEX_WAKE, 1) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 982754}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 983790}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 984355}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 984706}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 985111}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 985499}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 986088}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 986436}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 986916}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 987397}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 987872}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 988440}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 988823}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 989314}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 990029}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 990890}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 991803}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 992616}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 993105}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 993585}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 994014}, NULL) = 0
...

recv(4, "45678901234567890123456789012345"..., 8192, 0) = 1448
gettimeofday({1180973757, 172437}, NULL) = 0
recv(4, "23456789012345678901234567890123"..., 8192, 0) = 1448
gettimeofday({1180973757, 172576}, NULL) = 0
recv(4, "01234567890123456789012345678901"..., 8192, 0) = 1632
gettimeofday({1180973757, 172752}, NULL) = 0
recv(4, "", 8192, 0)                    = 0
gettimeofday({1180973757, 172797}, NULL) = 0
gettimeofday({1180973757, 172817}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL)                 = 0
close(4)                     = 0
futex(0x8055d04, 0x5 /* FUTEX_??? */, 1) = 1
futex(0x8055d30, FUTEX_WAKE, 1) = 0
_exit(0)

-- 
Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

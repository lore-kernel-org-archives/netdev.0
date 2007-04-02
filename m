From: CaT <cat@zip.com.au>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Mon, 2 Apr 2007 17:41:08 +1000
Message-ID: <20070402074108.GB8345@zip.com.au>
References: <20070402014319.GA8345@zip.com.au> <20070402001300.3b66007d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753373AbXDBHja@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070402001300.3b66007d.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 02, 2007 at 12:13:00AM -0700, Andrew Morton wrote:
> On Mon, 2 Apr 2007 11:43:19 +1000 CaT <cat@zip.com.au> wrote:
> 
> > I take minute by minute snapshots of network traffic by sampling
> > /proc/net/dev and most of the time everything works fine. Occasionally
> > though I get petabyte byte traffic and corresponding packet traffic.
> 
> How frequently?

I can count about 6 over the past month.

> Are you able to provide some actual numbers (expected and actual values),
> so we can look at the bit patterns?

I have them in an rrd file. I think though that the numbers will be
'adjusted' to fit in with the timekeeping. The logging code I've added
should provide exact numbers as it'll just dump what it reads from /proc
into syslog.

> > This happens on an AMD64, dual core smp box with Broadcom NetXtreme II
> > nics.
> 
> What driver drivers that?  b44.c?

bnx2

> > The issue happens with both nics but at different times. The same
> > sampling code runs on p4 boxes with ht on and e1000 nics without issues
> > so I don't believe it's an issue with my code (famous last words :)
> > which just does an re to extract the data on a per-line basis and prints
> > it out. Still, I'll be adding code to log any big readings and hopefully
> > it'll happen again sooner rather then later.
> > 
> > There is no preemption involved and the kernel is a monolythic build of
> > 2.6.19.[12] (there are two servers).
> 
> We do perform racy 64-bit updates of some of the stats counters.  But
> that'll only affect 32-bit kernels and I'm assuming you're running a 64-bit
> kernel on that AMD64 box (are you?)

Correct. The environment is 64bit clean, though the kernel is compiled
with 32bit support so that I can run static 32bit binaries if need be.

> Plus it's odd that both the byte-counters and the packet-counters go wonky
> at the same time.

If you want I can toss you the rrd graphs that result from the data. The
values do not appear to be static. For example, the resent 2 hits
(within 10 minutes of each other) gave almost 3petabytes and just over 4
petabytes. Interesting is that the incoming data is driven upto
petabytes whilst the outgoing data hits megabytes at that point. This is
consistant and the server is generally quiet.

-- 
    "To the extent that we overreact, we proffer the terrorists the
    greatest tribute."
    	- High Court Judge Michael Kirby

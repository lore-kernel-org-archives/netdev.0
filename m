From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: netconsole still hangs
Date: Wed, 12 Mar 2008 16:57:17 -0700
Message-ID: <20080312165717.c0879b1d.akpm@linux-foundation.org>
References: <20080312161429.d5b1c67b.akpm@linux-foundation.org>
	<20080312161637.b082b515.akpm@linux-foundation.org>
	<20080312163013.aaf07aa0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38569 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751952AbYCLX57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 19:57:59 -0400
In-Reply-To: <20080312163013.aaf07aa0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Mar 2008 16:30:13 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 12 Mar 2008 16:16:37 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed, 12 Mar 2008 16:14:29 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > 
> > > I thought the recent reverts fixed this, but it seems that it's just become
> > > a little harder to hit.
> > > 
> > > I'm seeing netconsole hangs on two x86_64 systems (2-way t61p laptop, 8-way
> > > server).  Both use e1000.
> > > 
> > > With current mainline on the 8-way, create a printk storm with
> > > 
> > > while true
> > > do
> > > 	echo t > /proc/sysrq-trigger
> > > done
> > > 
> > > and the machine goes tits-up after about five seconds.
> > > 
> > 
> > whoops, hang on, it's still running.
> 
> And it's still running!  I killed the above loop five minutes ago and
> nothing new is coming out in `dmesg -c', yet data is still flying out over
> netconsole.  hundreds and hundreds of megabytes.
> 
> So I'd say that something in netconsole or the console susbsytem has
> screwed up its buffer indices and it has gone infinite.
> 
> I don't know whether that's a regression though.
> 
> <does reboot -f>
> 
> OK, that stopped it, so the problem isn't buffering at the receiver.  I
> already knew that, because the ifconfig "TX bytes" counters were going up
> on the sending side.
> 
> <runs the sysrq-trigger thing again>
> 
> OK, this time it did hang up.  Machine unpingable, no signs of life.
> 

I reran the test on 2.6.24 and all seemed fine: the machine didn't hang and
stopping the script stopped the netconsole output.

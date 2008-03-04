From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: Re: locking api self-test hanging
Date: Tue, 4 Mar 2008 20:04:28 +0100
Message-ID: <20080304190424.GA6820@joi>
References: <20080203150246.50647fa4.akpm@linux-foundation.org> <20080203150744.cf7d0415.akpm@linux-foundation.org> <20080204044304.d244e761.akpm@linux-foundation.org> <20080206003412.dca555d4.akpm@linux-foundation.org> <20080303210540.cea55e13.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:38559 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762468AbYCDTFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 14:05:38 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1112787fga.17
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2008 11:05:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080303210540.cea55e13.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 09:05:40PM -0800, Andrew Morton wrote:
> On Wed, 6 Feb 2008 01:16:43 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed, 6 Feb 2008 00:34:12 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > On Mon, 4 Feb 2008 04:43:04 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> > > 
> > > > On Sun, 3 Feb 2008 15:07:44 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > 
> > > > > On Sun, 3 Feb 2008 15:02:46 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > > 
> > > > > > 
> > > > > > With current mainline I'm getting intermittent hangs here:
> > > > > > 
> > > > > > 	http://userweb.kernel.org/~akpm/p2033590.jpg
> > > > > > 
> > > > > > with this config:
> > > > > > 
> > > > > > 	http://userweb.kernel.org/~akpm/config-sony.txt
> > > > > > 
> > > > > > on the Vaio.  Sometimes it boots (then hits another different hang),
> > > > > > sometimes it gets stuck there.
> > > > 
> > > > CONFIG_DEBUG_LOCKING_API_SELFTESTS=n fixed that up.
> > > > 
> > > > > 
> > > > > The second hang is in kobject_uevent_init().  All that function does is call
> > > > > netlink_kernel_create().
> > > > 
> > > > And I've fully bisected this hang twice and both times came up with
> > > > 
> > > > commit 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7
> > > > Author: Stephen Hemminger <shemminger@linux-foundation.org>
> > > > Date:   Mon Nov 19 19:24:52 2007 -0800
> > > > 
> > > >     [NETPOLL]: Kill NETPOLL_RX_DROP, set but never tested.
> > > > 
> > > > which is stupid because that patch doesn't do anything.
> > > > 
> > > > However I am using netconsole-over-e100 and the hang does go away when I
> > > > disable netconsole on the kernel boot command line.
> > > > 
> > > > I'd say it's some timing thing in netpoll/netconsole/napi/etc.
> > > > 
> > > 
> > > I'm seeing this netconsole hang on a second machine now.  Current
> > > mainline.  It also has e100.  This one is SMP ancient PIII.
> > > 
> > > Config: http://userweb.kernel.org/~akpm/config-vmm.txt
> > > 
> > 
> > I can reproduce this on a third machine: the t61p laptop: dual x86_64 with
> > e1000.
> > 
> > It seems to need quite a lot of printk activity to make it happen.  Turning
> > on initcall_debug is a suitable way of triggering it.
> > 
I've seen it once too. But I thought it had something to do with this:
http://lkml.org/lkml/2008/3/2/91

> This netconsole regression is still present in current mainline.  Rafael,
> can you please add it to the list?
> 
> It's strange that I can hit it on three separate machines with e100 and e1000
> yet nobody else has reported it (afaik).  Is nobody using netconsole?

ps: I don't have any e100* card

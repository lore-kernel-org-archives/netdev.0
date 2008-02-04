From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: locking api self-test hanging
Date: Mon, 4 Feb 2008 05:18:45 -0800
Message-ID: <20080204051845.5e04a65d.akpm@linux-foundation.org>
References: <20080203150246.50647fa4.akpm@linux-foundation.org>
	<20080203150744.cf7d0415.akpm@linux-foundation.org>
	<20080204044304.d244e761.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56327 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752539AbYBDNSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 08:18:40 -0500
In-Reply-To: <20080204044304.d244e761.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Feb 2008 04:43:04 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sun, 3 Feb 2008 15:07:44 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Sun, 3 Feb 2008 15:02:46 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > 
> > > With current mainline I'm getting intermittent hangs here:
> > > 
> > > 	http://userweb.kernel.org/~akpm/p2033590.jpg
> > > 
> > > with this config:
> > > 
> > > 	http://userweb.kernel.org/~akpm/config-sony.txt
> > > 
> > > on the Vaio.  Sometimes it boots (then hits another different hang),
> > > sometimes it gets stuck there.
> 
> CONFIG_DEBUG_LOCKING_API_SELFTESTS=n fixed that up.
> 
> > 
> > The second hang is in kobject_uevent_init().  All that function does is call
> > netlink_kernel_create().
> 
> And I've fully bisected this hang twice and both times came up with
> 
> commit 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7
> Author: Stephen Hemminger <shemminger@linux-foundation.org>
> Date:   Mon Nov 19 19:24:52 2007 -0800
> 
>     [NETPOLL]: Kill NETPOLL_RX_DROP, set but never tested.
> 
> which is stupid because that patch doesn't do anything.
> 
> However I am using netconsole-over-e100 and the hang does go away when I
> disable netconsole on the kernel boot command line.
> 
> I'd say it's some timing thing in netpoll/netconsole/napi/etc.
> 

I expect the locking API self-tests are innocent - the netconsole lockup
happened to strike during the locking API tests and fooled me.  When I
disabled those tests, the netconsole lockup struck later on.  


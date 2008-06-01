From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool -
 e1000/pcnet32
Date: Sun, 1 Jun 2008 16:46:14 -0400
Message-ID: <20080601164614.012fe1f6.billfink@mindspring.com>
References: <482F610D.2080108@sngx.net>
	<20080518003104.GK28241@solarflare.com>
	<482FBA09.80201@sngx.net>
	<483E0AAE.2020107@sngx.net>
	<20080528221118.63da4092.akpm@linux-foundation.org>
	<483EA2D1.8050603@sngx.net>
	<20080529154525.3916c7b5@core>
	<20080530151250.b44a119a.billfink@mindspring.com>
	<20080531131143.516ca56e@core>
	<20080531195702.0b879dd1.billfink@mindspring.com>
	<20080601014620.GG30769@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	James Cammarata <jimi@sngx.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:45940
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751646AbYFAUqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 16:46:23 -0400
In-Reply-To: <20080601014620.GG30769@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 1 Jun 2008, Ben Hutchings wrote:

> Bill Fink wrote:
> <snip>
> > Yes, every individual Linux network administrator can re-create the
> > wheel by devising their own scripts, but it makes much more sense
> > to me to implement a simple general kernel mechanism once that could
> > be used generically, than to have hundreds (or thousands) of Linux
> > network administrators each having to do it themselves (perhaps
> > multiple times if they have a variety of types of systems and types
> > of NICs).
> 
> The ethtool interface is pretty generic, even if the names aren't.
> Here's some Python code I just knocked up which demonstrates how
> to get a set of named stats.  It shouldn't be terribly hard to
> extend this to saving and subtracting stat sets.

I'm not sure what that proves.  Your python code just basically gives
the same info as running the "ethtool -S" command.  But the question
is how does one devise a generic script or tool that doesn't require
any special knowledge of the specific NIC being used.  For example,
here's the "ethtool -S" info for my myri10ge NIC:

[root@chance8 ~]# ethtool -S eth2
NIC statistics:
     rx_packets: 53243864310
     tx_packets: 112826823797
     rx_bytes: 301727733072710
     tx_bytes: 716648208451198
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_boundary: 4096
     WC: 1
     irq: 8413
     MSI: 1
     read_dma_bw_MBs: 1398
     write_dma_bw_MBs: 1613
     read_write_dma_bw_MBs: 2711
     serial_number: 287046
     tx_pkt_start: 1157674101
     tx_pkt_done: 1157674101
     tx_req: 188226127
     tx_done: 188226127
     rx_small_cnt: 3009560676
     rx_big_cnt: 1726230729
     wake_queue: 57969440
     stop_queue: 57969440
     watchdog_resets: 0
     tx_linearized: 0
     link_changes: 8
     link_up: 1
     dropped_link_overflow: 0
     dropped_link_error_or_filtered: 26584
     dropped_multicast_filtered: 2190912
     dropped_runt: 0
     dropped_overrun: 0
     dropped_no_small_buffer: 0
     dropped_no_big_buffer: 0

How does one know which of these reported values are counter stats
that one wishes to zero/snapshot, and which are not?

Another issue that occurred to me is if multiple people are working
on troubleshooting a network problem, how do we insure that they all
get a consistent view of the stats?  If this is done via a kernel
mechanism then there isn't an issue.  But if it's done via user space,
then you have to make sure that everyone zeros/snapshots the stats
at the same time.

Ideally, one should be able to do something like "ethtool -z ethX"
to zero/snapshot the driver stats, and then "ethtool -S ethX" to get
the stats since the last snapshot.  You should be able to use the
same tool ("ethtool") to do all of this, and not some other special
tool or specially devised homegrown script.  Why make users lives
any more difficult than need be?

						-Bill

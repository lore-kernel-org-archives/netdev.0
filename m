From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: e1000 driver and samba
Date: Tue, 18 Sep 2007 10:04:37 -0700
Message-ID: <08FE5CC30C9A3F41BF819A502CF7BF6E02045257@fmsmsx411.amr.corp.intel.com>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com> <36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com> <20070918020358.d50653d5.billfink@mindspring.com> <ygfps0g8lj0.fsf@janus.isnogud.escape.de> <82k5qoxfbk.fsf@mid.bfk.de> <780b6f780709180932j5944b927p44ace42833e0230b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Urs Thuermann" <urs@isnogud.escape.de>,
	"Bill Fink" <billfink@mindspring.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"James Chapman" <jchapman@katalix.com>, <netdev@vger.kernel.org>
To: "L F" <lfabio.linux@gmail.com>, "Florian Weimer" <fweimer@bfk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65319 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757469AbXIRREj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 13:04:39 -0400
Content-class: urn:content-classes:message
In-Reply-To: <780b6f780709180932j5944b927p44ace42833e0230b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I ran a test here in the lab and was not able to reproduce the issue
you're describing. My setup is with 2 systems connected through a
100Mbit switch. Client runs Windows XP and the server is Linux RHEL5
with updated samba 3.0.26a (latest I could download from samba.org).

I was able to copy 1GB zip file back and forth and also decompress it
from/to the shared drive without data corruption. 

Have you looked into the data corruption - what is the difference
between the files? If the files have the same size you should be able to
see the diff with hexdump for example. 

Could you provide your samba config?

Thanks,
Emil

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of L F
Sent: Tuesday, September 18, 2007 9:32 AM
To: Florian Weimer
Cc: Urs Thuermann; Bill Fink; Brandeburg, Jesse; Kok, Auke-jan H; James
Chapman; netdev@vger.kernel.org
Subject: Re: e1000 driver and samba

This is the latest ethtool -S :
beehive:~# ethtool -S eth4
NIC statistics:
     rx_packets: 33491526
     tx_packets: 41410384
     rx_bytes: 28384277429
     tx_bytes: 46178788616
     rx_broadcast: 3144
     tx_broadcast: 2068
     rx_multicast: 79
     tx_multicast: 0
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 0
     multicast: 79
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 36256
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     tx_timeout_count: 0
     tx_restart_queue: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 0
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 37420
     rx_flow_control_xoff: 37420
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 28384277429
     rx_csum_offload_good: 33478553
     rx_csum_offload_errors: 0
     rx_header_split: 0
     alloc_rx_buff_failed: 0
     tx_smbus: 0
     rx_smbus: 0
     dropped_smbus: 0
There have been no further deferred frames, in accordance to what was
posted above. However, as Urs very correctly points out, the problem
is still very much there. I am waiting for new and improved cables
(third batch) to see if that makes a difference.
I am also wondering if, perhaps, a layer3 managed switch with port
statistics may prove helpful.
To answer Bill's questions, memtest+ 1.70 was run overnight, it
totalled some fifty passes with no errors. I know that some maintain
that memtest is not a definitive RAM test, but it certainly catches
most problems.
As to the disk side of the equation, that is of course a possible
concern and I will be running a second, more intensive batch of tests.
However, the fact that virtualbox (running on the server) reports no
errors despite running through significant amounts of data (10GB+,
passing through samba via the tap device that is bridged to the
problematic ethernet) every day makes me fairly confident that the
disk side of the equation is not where the problem lies.

LF
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

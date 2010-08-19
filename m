From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: bne2 rx packet drop?
Date: Thu, 19 Aug 2010 12:05:34 +0930
Message-ID: <201008191205.34696.rusty@rustcorp.com.au>
References: <201008050859.57659.rusty@rustcorp.com.au> <1280965623.7554.33.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42109 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944Ab0HSCfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 22:35:41 -0400
In-Reply-To: <1280965623.7554.33.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Aug 2010 09:17:03 am Michael Chan wrote:
> 
> On Wed, 2010-08-04 at 16:29 -0700, Rusty Russell wrote:
> > Hi Michael (and netdev!)
> > 
> >    I've got a customer seeing ~1000 rx packets dropped per day (on a busy
> > interface, bonding) via 'netstat -ni' RX-DRP's field across their 4-node
> > cluster.  The code seems to put checksum_discard and mac_discard into
> > that counter, so I'm not sure what the root cause is.
> 
> Please ask the customer for ethtool -S ethx.  It has a number of
> different counters for rx dropped packets so we can get a better idea of
> what's happening.

Thanks, finally got this.  Here's the ethtool -S from one of the quiet
interfaces:

NIC statistics:
    rx_bytes: 4490460
    rx_error_bytes: 0
    tx_bytes: 0
    tx_error_bytes: 0
    rx_ucast_packets: 0
    rx_mcast_packets: 0
    rx_bcast_packets: 31879
    tx_ucast_packets: 0
    tx_mcast_packets: 0
    tx_bcast_packets: 0
    tx_mac_errors: 0
    tx_carrier_errors: 0
    rx_crc_errors: 0
    rx_align_errors: 0
    tx_single_collisions: 0
    tx_multi_collisions: 0
    tx_deferred: 0
    tx_excess_collisions: 0
    tx_late_collisions: 0
    tx_total_collisions: 0
    rx_fragments: 0
    rx_jabbers: 0
    rx_undersize_packets: 0
    rx_oversize_packets: 0
    rx_64_byte_packets: 27241
    rx_65_to_127_byte_packets: 0
    rx_128_to_255_byte_packets: 0
    rx_256_to_511_byte_packets: 32
    rx_512_to_1023_byte_packets: 4606
    rx_1024_to_1522_byte_packets: 0
    rx_1523_to_9022_byte_packets: 0
    tx_64_byte_packets: 0
    tx_65_to_127_byte_packets: 0
    tx_128_to_255_byte_packets: 0
    tx_256_to_511_byte_packets: 0
    tx_512_to_1023_byte_packets: 0
    tx_1024_to_1522_byte_packets: 0
    tx_1523_to_9022_byte_packets: 0
    rx_xon_frames: 0
    rx_xoff_frames: 0
    tx_xon_frames: 0
    tx_xoff_frames: 0
    rx_mac_ctrl_frames: 0
    rx_filtered_packets: 4630821
    rx_discards: 0
    rx_fw_discards: 31876

Thanks!
Rusty.

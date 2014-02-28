From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: allow to transmit +4 byte in TX_RING
 slot for VLAN case
Date: Fri, 28 Feb 2014 16:52:34 -0500 (EST)
Message-ID: <20140228.165234.200477519056803957.davem@davemloft.net>
References: <1393550526-25390-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mathias.kretschmer@fokus.fraunhofer.de,
	greearb@candelatech.com, phil@nwl.cc
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbaB1Vwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 16:52:39 -0500
In-Reply-To: <1393550526-25390-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 28 Feb 2014 02:22:06 +0100

> Commit 57f89bfa2140 ("network: Allow af_packet to transmit +4 bytes
> for VLAN packets.") added the possibility for non-mmaped frames to
> send extra 4 byte for VLAN header so the MTU increases from 1500 to
> 1504 byte, for example.
> 
> Commit cbd89acb9eb2 ("af_packet: fix for sending VLAN frames via
> packet_mmap") attempted to fix that for the mmap part but was
> reverted as it caused regressions while using eth_type_trans()
> on output path.
> 
> Lets just act analogous to 57f89bfa2140 and add a similar logic
> to TX_RING. We presume size_max as overcharged with +4 bytes and
> later on after skb has been built by tpacket_fill_skb() check
> for ETH_P_8021Q header on packets larger than normal MTU. Can
> be easily reproduced with a slightly modified trafgen in mmap(2)
> mode, test cases:
> 
>  { fill(0xff, 12) const16(0x8100) fill(0xff, <1504|1505>) }
>  { fill(0xff, 12) const16(0x0806) fill(0xff, <1500|1501>) }
> 
> Note that we need to do the test right after tpacket_fill_skb()
> as sockets can have PACKET_LOSS set where we would not fail but
> instead just continue to traverse the ring.
> 
> Reported-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Looks good, applied, thanks Daniel.

From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: how to utilize multi tx queue to sent packets
Date: Fri, 11 Mar 2011 09:06:36 -0800
Message-ID: <20110311090636.6e393f2b@nehalam>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24FB3D3D62@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59232 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642Ab1CKRGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 12:06:41 -0500
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24FB3D3D62@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Mar 2011 22:52:30 -0800
Jon Zhou <Jon.Zhou@jdsu.com> wrote:

> hi
> 
> I am doing some test according to the
> website:http://wiki.ipxwarzone.com/index.php5?title=Linux_packet_mmap
> 
> use packet_mmap tx_ring to send packet.
> 
> I modified the sample code "packetmmap.c" to make it send packets have different outer ip.
> so that with the help of RSS, I can achieve higher throughput.
> 
> but one thing I saw at the tx side, is that all the packets are sent via the same tx_queue,
> which is conflict with what I saw at the rx side.
> any idea to make it sent packets via different tx_queues? (spread across the tx_queues)

You need to have multiple threads to get Tx scaling.
In you case that also means multiple AF_PACKET sockets and separate rings.

Or just run multiple copies of the same test each with a different IP

From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: how to utilize multi tx queue to sent packets
Date: Mon, 14 Mar 2011 11:14:43 -0700
Message-ID: <20110314111443.149b56a9@nehalam>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24FB3D3D62@MILEXCH2.ds.jdsu.net>
	<20110311090636.6e393f2b@nehalam>
	<4A6A2125329CFD4D8CC40C9E8ABCAB9F24FB47E9EE@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45467 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752465Ab1CNSOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 14:14:46 -0400
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24FB47E9EE@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Mar 2011 01:06:11 -0800
Jon Zhou <Jon.Zhou@jdsu.com> wrote:

> 
> 
> > -----Original Message-----
> > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > Sent: Saturday, March 12, 2011 1:07 AM
> > To: Jon Zhou
> > Cc: netdev@vger.kernel.org
> > Subject: Re: how to utilize multi tx queue to sent packets
> > 
> > On Thu, 10 Mar 2011 22:52:30 -0800
> > Jon Zhou <Jon.Zhou@jdsu.com> wrote:
> > 
> > > hi
> > >
> > > I am doing some test according to the
> > > website:http://wiki.ipxwarzone.com/index.php5?title=Linux_packet_mmap
> > >
> > > use packet_mmap tx_ring to send packet.
> > >
> > > I modified the sample code "packetmmap.c" to make it send packets
> > have different outer ip.
> > > so that with the help of RSS, I can achieve higher throughput.
> > >
> > > but one thing I saw at the tx side, is that all the packets are sent
> > via the same tx_queue,
> > > which is conflict with what I saw at the rx side.
> > > any idea to make it sent packets via different tx_queues? (spread
> > across the tx_queues)
> > 
> > You need to have multiple threads to get Tx scaling.
> > In you case that also means multiple AF_PACKET sockets and separate
> > rings.
> > 
> > Or just run multiple copies of the same test each with a different IP
> 
> How does kernel know which tx_queue to use?
> Will dev_queue_xmit determine tx_queue(sw queue) to send packets?
> Or just let NIC select a tx_queue(hardware) ?
> 

On most hardware, with multi-queue there is one queue per CPU.
In that case the queue selected corresponds to the CPU.



-- 

From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: RE: [PATCH net-next] be2net: Learn and program mac to avoid packet
 replication in nPAR mode.
Date: Mon, 8 Sep 2014 16:17:50 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C94055E@CMEXMB1.ad.emulex.com>
References: <206ffa9c-915e-4a1e-affe-68616cbef2f8@CMEXHTCAS1.ad.emulex.com>
 <20140905.173456.2115240943907507122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller (davem@davemloft.net)" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:30903 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbaIHQSR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 12:18:17 -0400
In-Reply-To: <20140905.173456.2115240943907507122.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, September 06, 2014 6:05 AM
> To: Venkat Duvvuru
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next] be2net: Learn and program mac to avoid
> packet replication in nPAR mode.
> 
> From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
> Date: Thu, 4 Sep 2014 20:00:59 +0530
> 
> > In a multi-channel setup, when an interface (channel/partition) is used
> > by a bridge or ovs, it is placed in promiscuous mode and the MAC addresses
> > of the VMs attached to the bridge are not configured on the base
> interface.
> > As a result of that, when a packet arrives to the port with
> > virtual machine's mac address, the card cannot determine which ring to
> > send the packet to, so replicates the packet on all the PFs of that port,
> > hence resulting in wastage of PCI bandwidth and CPU cycles. Packet
> replication
> > is also considered security risk as it can cause packets to reach an undesired
> VM.
> >
> > This patch will help solve the problem by learning the mac address and
> > programming it in the adapter. This patch also unlearns the MAC, if the
> MAC is
> > moved out of the machine or if the MAC is inactive for more than 5
> minutes.
> >
> > Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
> 
> This is non-trivial overhead to add to the fast paths of your primary
> packet input and output paths.
> 
> I think you need to find a different solution to this problem.

A few points why I don't think this is non-trivial overhead
1. Mac learning happens only when there is a MAC miss and this is really a "once in a while" scenario.
2. There is no contention in the data path unless there is a MAC miss. 
3. Our experiments show that 
	a. There is almost no impact on the CPU because of mac learning.
	b. Throughput is not affected when there is no packet replication and this patch significantly improves the performance compared to throughput in a packet replication scenario.

Please let me know your thoughts.

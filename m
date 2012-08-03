From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: [PATCH] mlx4_en: add UFO support
Date: Fri, 3 Aug 2012 08:29:26 +0000
Message-ID: <953B660C027164448AE903364AC447D2871F0CCC@MTLDAG01.mtl.com>
References: <1343940824-4720-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:39297 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752470Ab2HCI3m convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2012 04:29:42 -0400
In-Reply-To: <1343940824-4720-1-git-send-email-cascardo@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Mellanox Ethernet adapters support Large Segmentation Offload for UDP
> packets. The only change needed is using the proper header size when the
> packet is UDP instead of TCP.
> 
> This significantly increases performance for large UDP packets on platforms
> which have an expensive dma_map call, like pseries.
> 
> On a simple test with 64000 payload size, throughput has increased from
> about 6Gbps to 9.5Gbps, while CPU use dropped from about 600% to about
> 80% or less, on a 8-core Power7 machine.
> 
Hi Thadeu,
Can you please send the info regarding the adapter you are testing with? What test are you running?
I just tried this patch with netperf on my x86_64, and it doesn't work. Packets are not fragmented properly (fragment offsets are not calculated).
It is true that the TX side doesn't work as hard (OS doesn't need to do the fragmentation), but traffic is not sent properly on the wire.

I'll do further investigation and get back with more details.

Yevgeny

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4_en: add UFO support
Date: Fri, 3 Aug 2012 10:54:19 -0300
Message-ID: <20120803135419.GB5736@oc1711230544.ibm.com>
References: <1343940824-4720-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <953B660C027164448AE903364AC447D2871F0CCC@MTLDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:57977 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835Ab2HCNyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 09:54:31 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Fri, 3 Aug 2012 10:54:26 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 128BC3520050
	for <netdev@vger.kernel.org>; Fri,  3 Aug 2012 09:54:21 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q73DrWqC27131998
	for <netdev@vger.kernel.org>; Fri, 3 Aug 2012 10:53:33 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q73BsA1w010843
	for <netdev@vger.kernel.org>; Fri, 3 Aug 2012 08:54:11 -0300
Content-Disposition: inline
In-Reply-To: <953B660C027164448AE903364AC447D2871F0CCC@MTLDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 03, 2012 at 08:29:26AM +0000, Yevgeny Petrilin wrote:
> > 
> > Mellanox Ethernet adapters support Large Segmentation Offload for UDP
> > packets. The only change needed is using the proper header size when the
> > packet is UDP instead of TCP.
> > 
> > This significantly increases performance for large UDP packets on platforms
> > which have an expensive dma_map call, like pseries.
> > 
> > On a simple test with 64000 payload size, throughput has increased from
> > about 6Gbps to 9.5Gbps, while CPU use dropped from about 600% to about
> > 80% or less, on a 8-core Power7 machine.
> > 
> Hi Thadeu,
> Can you please send the info regarding the adapter you are testing with? What test are you running?
> I just tried this patch with netperf on my x86_64, and it doesn't work. Packets are not fragmented properly (fragment offsets are not calculated).
> It is true that the TX side doesn't work as hard (OS doesn't need to do the fragmentation), but traffic is not sent properly on the wire.
> 
> I'll do further investigation and get back with more details.
> 
> Yevgeny
> 

Hi, Yevgeny.

You are right. After generating a dump on the receiving end, and sending
a single large packet, I did notice that fragment offsets were all 0,
more fragments flag is not set and id is incremented.

Does the hardware really support UFO as documented? Should we just write
the IP header to the descriptor? I will try this and report my results.
Meanwhile, can you find out what is needed to get this working?

Thanks a lot.
Cascardo.

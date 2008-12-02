From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] lro: IP fragment checking
Date: Mon, 01 Dec 2008 19:19:01 -0500
Message-ID: <49347EF5.2010206@myri.com>
References: <493423D7.5030203@myri.com>	<20081201.131810.158631503.davem@davemloft.net>	<49345CCA.1030209@myri.com> <20081201.160722.114600830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tklein@de.ibm.com, raisch@de.ibm.com,
	jb.billaud@gmail.com, hering2@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1883 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753125AbYLBATM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 19:19:12 -0500
In-Reply-To: <20081201.160722.114600830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andrew Gallatin <gallatin@myri.com>
> Date: Mon, 01 Dec 2008 16:53:14 -0500
> 
>> What hardware does an explicit check for fragmentation?
> 
> If the packet is fragmented, the chip shouldn't even be
> looking at the ports to make LRO deferral decisions let
> alone pass it down as a LRO'able frame.

You seem to be assuming that all consumers of the Linux LRO
interface have support for LRO in hardware.  Many (most?)
do not.  The way software LRO works in these drivers is the
driver just sends all packets through lro_receive_skb() when
LRO is configured and enabled.  The LRO layer then filters
out things which are not eligible for LRO.  See, for example,
igb_receive_skb().

If you're arguing that the hardware should have checked for
fragmentation, then many (most?) things in lro_tcp_ip_check()
should be removed.  They are all basic sanity checks for
packets that would not be considered for LRO by a hardware
implementation, but are required by a software implementation
where all packets are through the LRO code.

Drew

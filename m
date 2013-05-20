From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6] rps: selective flow shedding during
 softnet overflow
Date: Mon, 20 May 2013 13:48:34 -0700 (PDT)
Message-ID: <20130520.134834.1375626486485314664.davem@davemloft.net>
References: <20130425.042007.1583080085524610665.davem@davemloft.net>
	<1369058552-2909-1-git-send-email-willemb@google.com>
	<1369065654.3301.184.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37774 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756298Ab3ETUsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:48:35 -0400
In-Reply-To: <1369065654.3301.184.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 May 2013 09:00:54 -0700

> On Mon, 2013-05-20 at 10:02 -0400, Willem de Bruijn wrote:
>> A cpu executing the network receive path sheds packets when its input
>> queue grows to netdev_max_backlog. A single high rate flow (such as a
>> spoofed source DoS) can exceed a single cpu processing rate and will
>> degrade throughput of other flows hashed onto the same cpu.
>> 
>> This patch adds a more fine grained hashtable. If the netdev backlog
>> is above a threshold, IRQ cpus track the ratio of total traffic of
>> each flow (using 4096 buckets, configurable). The ratio is measured
>> by counting the number of packets per flow over the last 256 packets
>> from the source cpu. Any flow that occupies a large fraction of this
>> (set at 50%) will see packet drop while above the threshold.
>> 
>> Tested:
>> Setup is a muli-threaded UDP echo server with network rx IRQ on cpu0,
>> kernel receive (RPS) on cpu0 and application threads on cpus 2--7
>> each handling 20k req/s. Throughput halves when hit with a 400 kpps
>> antagonist storm. With this patch applied, antagonist overload is
>> dropped and the server processes its complete load.
>> 
>> The patch is effective when kernel receive processing is the
>> bottleneck. The above RPS scenario is a extreme, but the same is
>> reached with RFS and sufficient kernel processing (iptables, packet
>> socket tap, ..).
>> 
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> 
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks guys.

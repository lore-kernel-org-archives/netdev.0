From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better
 sleep/wakeup efficiency
Date: Wed, 21 May 2014 15:51:00 -0400 (EDT)
Message-ID: <20140521.155100.1364245684110064848.davem@davemloft.net>
References: <1400278308-25372-1-git-send-email-xii@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, mst@redhat.com,
	maxk@qti.qualcomm.com, ncardwell@google.com, edumazet@google.com
To: xii@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbaEUTvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 15:51:02 -0400
In-Reply-To: <1400278308-25372-1-git-send-email-xii@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xi Wang <xii@google.com>
Date: Fri, 16 May 2014 15:11:48 -0700

> tun_do_read always adds current thread to wait queue, even if a packet
> is ready to read. This is inefficient because both sleeper and waker
> want to acquire the wait queue spin lock when packet rate is high.
> 
> We restructure the read function and use common kernel networking
> routines to handle receive, sleep and wakeup. With the change
> available packets are checked first before the reading thread is added
> to the wait queue.
> 
> Ran performance tests with the following configuration:
> 
>  - my packet generator -> tap1 -> br0 -> tap0 -> my packet consumer
>  - sender pinned to one core and receiver pinned to another core
>  - sender send small UDP packets (64 bytes total) as fast as it can
>  - sandy bridge cores
>  - throughput are receiver side goodput numbers
> 
> The results are
> 
> baseline: 731k pkts/sec, cpu utilization at 1.50 cpus
>  changed: 783k pkts/sec, cpu utilization at 1.53 cpus
> 
> The performance difference is largely determined by packet rate and
> inter-cpu communication cost. For example, if the sender and
> receiver are pinned to different cpu sockets, the results are
> 
> baseline: 558k pkts/sec, cpu utilization at 1.71 cpus
>  changed: 690k pkts/sec, cpu utilization at 1.67 cpus
> 
> Co-authored-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Xi Wang <xii@google.com>

Applied to net-next, thanks.

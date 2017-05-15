From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rps: don't skip offline cpus when set
 rps_cpus
Date: Mon, 15 May 2017 10:23:30 -0400 (EDT)
Message-ID: <20170515.102330.1406781282658945993.davem@davemloft.net>
References: <20170515125552.2971-1-zlpnobody@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, zlpnobody@gmail.com
To: zlpnobody@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35322 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965524AbdEOOXh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 10:23:37 -0400
In-Reply-To: <20170515125552.2971-1-zlpnobody@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@163.com>
Date: Mon, 15 May 2017 20:55:52 +0800

> From: Liping Zhang <zlpnobody@gmail.com>
> 
> On our 4-core system, sometimes I can enable all CPUs to process packets.
> But sometimes I can't, if all the CPUs become offline except core 0, I
> will get the following result, which is really annoying for my script:
>  # echo f > /sys/class/net/eth0/queues/rx-0/rps_cpus
>  # cat /sys/class/net/eth0/queues/rx-0/rps_cpus
>  1
> 
> Since we won't steer the packets to these offline cpus, it's reasonable
> to enable all configed cpus to the rps_map, even if they are offline for
> the time being.
> 
> Signed-off-by: Liping Zhang <zlpnobody@gmail.com>

But this means while those cpus are offline, get_rps_cpu() performs
very suboptimally.

In fact, if the packet hashes to one of those offline cpus, you get
no RPS at all.

So I think we really can't make this change, at least in it's current
form.

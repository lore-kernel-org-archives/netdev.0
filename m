From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: sch_generic: Fix oops in sch_teql
Date: Sun, 19 Oct 2008 23:38:11 -0700 (PDT)
Message-ID: <20081019.233811.252670245.davem@davemloft.net>
References: <20081018230938.GC6048@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38364
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751336AbYJTGie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 02:38:34 -0400
In-Reply-To: <20081018230938.GC6048@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 19 Oct 2008 01:09:38 +0200

> pkt_sched: sch_generic: Fix oops in sch_teql
> 
> After these commands:
> # modprobe sch_teql
> # tc qdisc add dev eth0 root teql0
> # tc qdisc del dev eth0 root
> we get an oops in teql_destroy() when spin_lock is taken from a null
> qdisc_sleeping pointer. It's because at the moment teql0 dev haven't
> been activated yet, and a qdisc_root_sleeping() is pointing to noop
> qdisc's netdev_queue with qdisc_sleeping uninitialized. This patch
> fixes this both for noop and noqueue netdev_queues to avoid similar
> problems in the future.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> [regression in 2.6.27]

Applied and will queue to -stable, thanks Jarek.

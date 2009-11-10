From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 11:29:00 +0100
Message-ID: <4AF9406C.8010603@trash.net>
References: <4AF924A5.1050303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63679 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbZKJK3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 05:29:02 -0500
In-Reply-To: <4AF924A5.1050303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> ifb: add multi-queue support
> 
> Add multi-queue support, and one kernel thread is created for per queue.
> It can used to emulate multi-queue NIC in software, and distribute work
> among CPUs.
> gentux linux # modprobe ifb numtxqs=2
> gentux linux # ifconfig ifb0 up
> gentux linux # pgrep ifb0
> 18508
> 18509
> gentux linux # taskset -p 1 18508
> pid 18508's current affinity mask: 3
> pid 18508's new affinity mask: 1
> gentux linux # taskset -p 2 18509
> pid 18509's current affinity mask: 3
> pid 18509's new affinity mask: 2
> gentux linux # tc qdisc add dev br0 ingress
> gentux linux # tc filter add dev br0 parent ffff: protocol ip basic
> action mirred egress redirect dev ifb0

I'm not sure how this will help, ifb device transmission is
still serialized by the ingress queue lock and the mirred lock.

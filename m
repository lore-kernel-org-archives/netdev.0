From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-rfs: fix false sharing accessing
 sd->input_queue_head
Date: Wed, 27 Apr 2016 00:31:31 -0400 (EDT)
Message-ID: <20160427.003131.1629120469234890217.davem@davemloft.net>
References: <1461709807.5535.55.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbcD0Ebd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 00:31:33 -0400
In-Reply-To: <1461709807.5535.55.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Apr 2016 15:30:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> sd->input_queue_head is incremented for each processed packet
> in process_backlog(), and read from other cpus performing
> Out Of Order avoidance in get_rps_cpu()
> 
> Moving this field in a separate cache line keeps it mostly
> hot for the cpu in process_backlog(), as other cpus will
> only read it.
> 
> In a stress test, process_backlog() was consuming 6.80 % of cpu cycles,
> and the patch reduced the cost to 0.65 %
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, nice work Eric.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] inet: fix double request socket freeing
Date: Mon, 23 Mar 2015 21:41:14 -0400 (EDT)
Message-ID: <20150323.214114.813876422885118707.davem@davemloft.net>
References: <550FEA98.3040009@gmail.com>
	<1427130389.25985.76.camel@edumazet-glaptop2.roam.corp.google.com>
	<1427148041.25985.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengyuleidian0615@gmail.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbbCXBlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 21:41:19 -0400
In-Reply-To: <1427148041.25985.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Mar 2015 15:00:41 -0700

> From: Fan Du <fan.du@intel.com>
> 
> Eric Hugne reported following error :
> 
> I'm hitting this warning on latest net-next when i try to SSH into a machine
> with eth0 added to a bridge (but i think the problem is older than that)
> 
> Steps to reproduce:
> node2 ~ # brctl addif br0 eth0
> [  223.758785] device eth0 entered promiscuous mode
> node2 ~ # ip link set br0 up
> [  244.503614] br0: port 1(eth0) entered forwarding state
> [  244.505108] br0: port 1(eth0) entered forwarding state
 ...
> Remove the double calls to reqsk_put()
> 
> [edumazet] :
> 
> I got confused because reqsk_timer_handler() _has_ to call
> reqsk_put(req) after calling inet_csk_reqsk_queue_drop(), as
> the timer handler holds a reference on req.
> 
> Signed-off-by: Fan Du <fan.du@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Erik Hugne <erik.hugne@ericsson.com>
> Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")

Applied, thanks Eric.

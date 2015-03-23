From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: fix double request socket freeing
Date: Mon, 23 Mar 2015 17:01:18 -0400 (EDT)
Message-ID: <20150323.170118.1601171271014763673.davem@davemloft.net>
References: <20150323090317.GB8934@haze>
	<550FEA98.3040009@gmail.com>
	<1427130389.25985.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengyuleidian0615@gmail.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58268 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbbCWVBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 17:01:21 -0400
In-Reply-To: <1427130389.25985.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Mar 2015 10:06:29 -0700

> From: Fan Du <fan.du@intel.com>
> 
> Eric Hugne reported following error :
> 
> I'm hitting this warning on latest net-next when i try to SSH into a machine
> with eth0 added to a bridge (but i think the problem is older than that)
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

This not longer applies after I installed your part 15 listener rework
patch set.

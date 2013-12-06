From: David Miller <davem@davemloft.net>
Subject: Re: [patch net/stable v2] br: fix use of ->rx_handler_data in code
 executed on non-rx_handler path
Date: Fri, 06 Dec 2013 15:43:21 -0500 (EST)
Message-ID: <20131206.154321.1673089712073824539.davem@davemloft.net>
References: <1386257257-25258-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jtluka@redhat.com, zhiguohong@tencent.com,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	edumazet@google.com, laine@redhat.com, mst@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3LFUnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 15:43:23 -0500
In-Reply-To: <1386257257-25258-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  5 Dec 2013 16:27:37 +0100

> br_stp_rcv() is reached by non-rx_handler path. That means there is no
> guarantee that dev is bridge port and therefore simple NULL check of
> ->rx_handler_data is not enough. There is need to check if dev is really
> bridge port and since only rcu read lock is held here, do it by checking
> ->rx_handler pointer.
> 
> Note that synchronize_net() in netdev_rx_handler_unregister() ensures
> this approach as valid.
> 
> Introduced originally by:
> commit f350a0a87374418635689471606454abc7beaa3a
>   "bridge: use rx_handler_data pointer to store net_bridge_port pointer"
> 
> Fixed but not in the best way by:
> commit b5ed54e94d324f17c97852296d61a143f01b227a
>   "bridge: fix RCU races with bridge port"
> 
> Reintroduced by:
> commit 716ec052d2280d511e10e90ad54a86f5b5d4dcc2
>   "bridge: fix NULL pointer deref of br_port_get_rcu"
> 
> Please apply to stable trees as well. Thanks.
> 
> RH bugzilla reference: https://bugzilla.redhat.com/show_bug.cgi?id=1025770
> 
> Reported-by: Laine Stump <laine@redhat.com>
> Debugged-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
> v1->v2: moved br_port_get_check_rcu definition below br_handle_frame definition

Applied and queued up for -stable, thanks Jiri.

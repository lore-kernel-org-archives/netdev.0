From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: tcp: get rid of ugly unicast_sock
Date: Sun, 01 Feb 2015 23:06:33 -0800 (PST)
Message-ID: <20150201.230633.1092529804938943818.davem@davemloft.net>
References: <1422596105.21689.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932245AbbBBHGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 02:06:34 -0500
In-Reply-To: <1422596105.21689.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Jan 2015 21:35:05 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit be9f4a44e7d41 ("ipv4: tcp: remove per net tcp_sock")
> I tried to address contention on a socket lock, but the solution
> I chose was horrible :
> 
> commit 3a7c384ffd57e ("ipv4: tcp: unicast_sock should not land outside
> of TCP stack") addressed a selinux regression.
> 
> commit 0980e56e506b ("ipv4: tcp: set unicast_sock uc_ttl to -1")
> took care of another regression.
> 
> commit b5ec8eeac46 ("ipv4: fix ip_send_skb()") fixed another regression.
> 
> commit 811230cd85 ("tcp: ipv4: initialize unicast_sock sk_pacing_rate")
> was another shot in the dark.
> 
> Really, just use a proper socket per cpu, and remove the skb_orphan()
> call, to re-enable flow control.
> 
> This solves a serious problem with FQ packet scheduler when used in
> hostile environments, as we do not want to allocate a flow structure
> for every RST packet sent in response to a spoofed packet.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

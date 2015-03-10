From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6] tcp_metrics: Add a field tcpm_net and
 verify it matches on lookup
Date: Tue, 10 Mar 2015 12:36:42 -0400 (EDT)
Message-ID: <20150310.123642.2054908032137423526.davem@davemloft.net>
References: <87oao2yqh1.fsf_-_@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1503092210150.1846@ja.home.ssi.bg>
	<87pp8hnxqz.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbbCJQgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 12:36:50 -0400
In-Reply-To: <87pp8hnxqz.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 10 Mar 2015 01:59:48 -0500

> If we actually really care about struct net going away it would be
> much better to globally replace struct net with a typedef that looks
> something like:
> 
> #ifdef CONFIG_NET_NS
> struct net_ref {
>        struct net *;
> };
> #else
> struct net_ref {
> };
> #endif
> typedef struct net_ref net_t;
> 
> That would remove the need for write_pnet and read_pnet, make it
> impossible to forget net_eq and make network namespace arguments to
> functions also boil away at compile time if the network namespace code
> was not enabled.
> 
> That was the original design and I forget why we didn't do that with
> struct net.  But we did not.

This keeps the ifdefs out of foo.c code, so I like it.

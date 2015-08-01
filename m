From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] ipv6: Turn on auto IPv6 flow labels by
 default
Date: Fri, 31 Jul 2015 17:07:28 -0700 (PDT)
Message-ID: <20150731.170728.1065099242090941932.davem@davemloft.net>
References: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbbHAAH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 20:07:29 -0400
In-Reply-To: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 31 Jul 2015 16:52:09 -0700

> BSD (MacOS) has already turned on flow labels by default and this does
> not seem to be causing any problems in the Internet. Let's go ahead
> and turn them on by default. We'll continue to monitor for any devices
> start choking on them.
> 
> Flow labels are important since they are the desired solution for
> network devices to perform ECMP and RSS (RFC6437 and RFC6438).
> Traditionally, devices perform a 5-tuple hash on packets that
> includes port numbers. For the most part, these devices can only
> compute 5-tuple hashes for TCP and UDP. This severely limits our ability
> to get good network load balancing for other protocols (IPIP, GRE,ESP,
> etc.), and hence we are limited in using other protocols. Unfortunately,
> this method is accepted as the de facto standard to the extent that
> there are several proposals to encapsulate protocols in UDP _just_ for
> the purposes for getting ECMP to work. With hosts generating flow labels
> and devices taking them as input into ECMP (several already do), we can
> start to fix this fundamental problem. 
> 
> This patch set:
>  - Changes IPV6_FLOWINFO sockopt to be opt-out of flow labels for
>    connections rather than opt-in
>  - Disable flow label state ranges sysctl by default
>  - Enable auto flow labels sysctl by default
> 
> v2:
>   - Added functions to create an skb->hash based on flowi4 and flowi6.
>     These are called in output path when creating a packet
>   - Call skb_get_hash_flowi6 in ip6_make_flowlabel
>   - Implement the auto_flowlabels sysctl as a mode for auto flowlabels.
>     There are four modes which correspond to flow labels being enabled
>     and whether socket option can be used to opt in or opt out of
>     using them

Looks good, series applied, thanks Tom.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] ipv6: Turn on auto IPv6 flow labels by
 default
Date: Thu, 30 Jul 2015 16:13:38 -0700 (PDT)
Message-ID: <20150730.161338.130333553135883566.davem@davemloft.net>
References: <1438275262-3708460-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbG3XNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 19:13:40 -0400
In-Reply-To: <1438275262-3708460-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 30 Jul 2015 09:54:19 -0700

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

I am pretty sure administrators are going to want a way to enforce that
all applications must use flow labels.

So can you add a third mode that turns on auto-flow-label, but
disallows the application level opt-out?

Thanks.

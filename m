From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] fib_rules: Added NLM_F_EXCL support to
 fib_nl_newrule
Date: Thu, 30 Jun 2016 08:24:31 -0400 (EDT)
Message-ID: <20160630.082431.1308534563356523412.davem@davemloft.net>
References: <57737722.6000101@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mateusz.bajorski@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbcF3MZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 08:25:00 -0400
In-Reply-To: <57737722.6000101@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mateusz Bajorski <mateusz.bajorski@nokia.com>
Date: Wed, 29 Jun 2016 09:22:10 +0200

> When adding rule with NLM_F_EXCL flag then check if the same rule exist.
> If yes then exit with -EEXIST.
> 
> This is already implemented in iproute2:
>         if (cmd == RTM_NEWRULE) {
>                 req.n.nlmsg_flags |= NLM_F_CREATE|NLM_F_EXCL;
>                 req.r.rtm_type = RTN_UNICAST;
>         }
> 
> Tested ipv4 and ipv6 with net-next linux on qemu x86
> 
> expected behavior after patch:
> localhost ~ # ip rule
> 0:    from all lookup local
> 32766:    from all lookup main
> 32767:    from all lookup default
> localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
> localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
> RTNETLINK answers: File exists
> localhost ~ # ip rule
> 0:    from all lookup local
> 1005:    from 10.46.177.97 lookup 104
> 32766:    from all lookup main
> 32767:    from all lookup default
> 
> There was already topic regarding this but I don't see any changes
> merged and problem still occurs.
> https://lkml.kernel.org/r/1135778809.5944.7.camel+%28%29+localhost+%21+localdomain
> 
> Signed-off-by: Mateusz Bajorski <mateusz.bajorski@nokia.com>

Applied to net-next, thanks.

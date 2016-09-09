From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] ip: fix creation flags reported in
 RTM_NEWROUTE events
Date: Fri, 09 Sep 2016 16:51:26 -0700 (PDT)
Message-ID: <20160909.165126.2106988715172525727.davem@davemloft.net>
References: <20160907151850.g3mzjrkhtqddqzwg@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com, milon@wq.cz,
        mkubecek@suse.cz, nicolas.dichtel@6wind.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33742 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbcIIXv2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:51:28 -0400
In-Reply-To: <20160907151850.g3mzjrkhtqddqzwg@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 7 Sep 2016 17:18:50 +0200

> Netlink messages sent to user-space upon RTM_NEWROUTE events have their
> nlmsg_flags field inconsistently set. While the NLM_F_REPLACE and
> NLM_F_APPEND bits are correctly handled, NLM_F_CREATE and NLM_F_EXCL
> are always 0.
> 
> This series sets the NLM_F_CREATE and NLM_F_EXCL bits when applicable,
> for IPv4 and IPv6.
> 
> Since IPv6 ignores the NLM_F_APPEND flags in requests, this flag isn't
> reported in RTM_NEWROUTE IPv6 events. This keeps IPv6 internal
> consistency (same flag semantic for user requests and kernel events) at
> the cost of bringing different flag interpretation for IPv4 and IPv6.

I'm applying this series to net-next so that it has time to cook and
expose anything in userland that might break due to these changes.

I briefly considered applying this to net but I think that is
premature at least for the time being.

Thanks.

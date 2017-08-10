From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] rtnetlink: allow selected handlers to
 run without rtnl
Date: Wed, 09 Aug 2017 17:21:14 -0700 (PDT)
Message-ID: <20170809.172114.233866755819084584.davem@davemloft.net>
References: <20170809184153.16700-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48286 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752497AbdHJAVP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:21:15 -0400
In-Reply-To: <20170809184153.16700-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  9 Aug 2017 20:41:46 +0200

> Changes since v1:
>  In patch 6, don't make ipv6 route handlers lockless, they all have
>  assumptions on rtnl being held.  Other patches are unchanged.
> 
> The RTNL mutex is used to serialize both rtnetlink calls and
> dump requests.
> Its also used to protect other things such as the list of current
> net namespaces.
> 
> Unfortunately RTNL mutex is a performance issue, e.g. a cpu adding an
> ip address prevents other cpus from seemingly unrelated tasks such as
> dumping tc classifiers or doing rtnetlink route lookups.
> 
> This patch set adds basic infrastructure to start pushing the rtnl lock
> down to those places that need it, or even elide it entirely in some cases.
> 
> Subsystems can now indicate that their doit() callback can run without
> RTNL mutex, such callbacks can then run in parallel.
> 
> This will obviously need a lot of followup work; all current
> users need to be audited/changed to benefit from this.
> Initial no-rtnl spot is netns new/getid.
> 
> We have various 'get' handlers that are also a tempting target,
> however, several of these depend on rtnl mutex to prevent information
> from changing while objects are being read by rtnl handlers; however,
> it doesn't appear impossible to change this.
> 
> Dumps are another problem entirely, see
> commit 2907c35ff64708065 ("net: hold rtnl again in dump callbacks"),
> this patchset doesn't touch dump requests.

Ok series applied, let's see where this goes :-)

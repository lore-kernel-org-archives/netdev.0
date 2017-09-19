From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 03/14] gtp: Call common functions to get tunnel
 routes and add dst_cache
Date: Tue, 19 Sep 2017 20:09:42 +0800
Message-ID: <20170919120942.dpy5kmkhzws7pqd5@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-4-tom@quantonium.net>
 <20170918.211751.1871429944584121281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@quantonium.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:45320 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdISMNN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:13:13 -0400
Content-Disposition: inline
In-Reply-To: <20170918.211751.1871429944584121281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Mon, Sep 18, 2017 at 09:17:51PM -0700, David Miller wrote:
> This and the new dst caching code ignores any source address selection
> done by ip_route_output_key() or the new tunnel route lookup helpers.
> 
> Either source address selection should be respected, or if saddr will
> never be modified by a route lookup for some specific reason here,
> that should be documented.

The IP source address is fixed by signaling on the GTP-C control plane
and nothing that the kernel can unilaterally decide to change.  Such a
change of address would have to be decided by and first be signaled on
GTP-C to the peer by the userspace daemon, which would then update the
PDP context in the kernel.

So I guess you're asking us to document that rationale as form of a
source code comment ?

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

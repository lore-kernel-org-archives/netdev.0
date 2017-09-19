From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 08/14] gtp: Support encpasulating over IPv6
Date: Tue, 19 Sep 2017 19:59:54 +0800
Message-ID: <20170919115954.xeycbdhvrfiwkbmq@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-9-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:45337 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750973AbdISMNN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:13:13 -0400
Content-Disposition: inline
In-Reply-To: <20170919003904.5124-9-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Mon, Sep 18, 2017 at 05:38:58PM -0700, Tom Herbert wrote:
> Allow peers to be specified by IPv6 addresses.

> +	u16			peer_af;
> +	union {
> +		struct in_addr	peer_addr_ip4;
> +		struct in6_addr	peer_addr_ip6;
> +	};

this will not really work, as an union means that a PDP context
will be either IPv4-only or IPV6-only, while in reality there
are three types, see my other mail.  So you have to  deal
with v4-only, v6-only or v4v6.

The v6-only is legacy by now, and all modern phones I've tested in
recent years can do v4v6 rather than having a v4-only and a v6-only
PDP context in parallel.

>From the operator point of view, v4v6 is very desirable, as it basically
halves the amount of PDP contexts compared to the old approach, which
significantly reduces signalling load across your network, as well as
the amount of memory (and thus capacity) in your core network elements.

I've recently implemented v6 + v4v6 support in osmo-ggsn (see
http://git.osmocom.org/osmo-ggsn/) in case you would like to see another
FOSS implementation for v6 + v4v6 - though in userspace, of course.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

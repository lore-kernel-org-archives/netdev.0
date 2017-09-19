From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 07/14] gtp: Support encapsulation of IPv6 packets
Date: Tue, 19 Sep 2017 19:53:27 +0800
Message-ID: <20170919115327.zbu5s2dnndj2ufx5@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-8-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:45334 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751519AbdISMNN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:13:13 -0400
Content-Disposition: inline
In-Reply-To: <20170919003904.5124-8-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 05:38:57PM -0700, Tom Herbert wrote:
> Allow IPv6 mobile subscriber packets. This entails adding an IPv6 mobile
> subscriber address to pdp context and IPv6 specific variants to find pdp
> contexts by address.

Please note that there are three different PDP contexts for IP:
* IPv4 only (what gtp.c implements so far)
* IPv6 only
* dual IPv4+IPv6 (called IPv46)

This information will have to be provisioned by the control plane
via netlink for each PDP context.  The kernel module then needs to
make sure that on a v4-only context no IPv6 packets are accepted
and vice-versa.

Your proposed patch is missing this kind of screening function and
I would imagine it could introduce all kinds of security problems :/

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

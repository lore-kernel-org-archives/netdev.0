From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC PATCH net-next 0/3] ethtool: Add link down reason
 reporting
Date: Wed, 21 Jun 2017 21:14:43 -0700
Message-ID: <20170621211443.674e18a6@cakuba.netronome.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:10758 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750924AbdFVEOw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 00:14:52 -0400
In-Reply-To: <1498050286-17141-1-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jun 2017 16:04:43 +0300, Gal Pressman wrote:
> Hi All,
> 
> Currently, drivers can only tell whether the link is up/down through
> ETHTOOL_GLINK callback, but no additional information is given in case
> of link down/failure.
> 
> This series provides an infrastructure to ethtool that allows 
> netdevice drivers to hint the user with the reason why the link is down,
> in order to ease the debug process.
> 
> In addition two more mlx5 patches to demonstrate the usage.
> 
> Reasons are separated to two types, generic and vendor specific.
> Drivers can reply with a generic reason using the predefined enums 
> (and the ones that will be added in the future), which will be
> translated to strings by the userspace ethtool.
> In case of a vendor specific reason, drivers can reply with
> ETHTOOL_VENDOR_SPECIFIC reason, in this case the vendor_reason field
> should be filled with a vendor specific status code which will be parsed
> by the vendor specific userspace parser if one is available.
> 
> This kind of information can save system administrators precious time,
> which will not be wasted trying to understand why the link won't go up.
>     
> For example, when the cable is unplugged:
>     $ ethtool ethXX
>     ...
>     Link detected: no (Cable unplugged)

Any particular reason for implementing this ABI in ethtool rather than
via some netlink-based interface?  Devlink naturally comes to mind,
given that cabling problems are not really related to the L2 and netdev
shouldn't be required for diagnostics..

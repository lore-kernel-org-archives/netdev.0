From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [RFC net-next 1/4] net: ipv6: Make inet6addr_validator a
 blocking notifier
Date: Wed, 11 Oct 2017 16:08:45 +0300
Message-ID: <20171011130845.GA11493@splinter>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
 <1507653665-20540-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36009 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752047AbdJKNIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 09:08:51 -0400
Content-Disposition: inline
In-Reply-To: <1507653665-20540-2-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 09:41:02AM -0700, David Ahern wrote:
> inet6addr_validator chain was added by commit 3ad7d2468f79f ("Ipvlan
> should return an error when an address is already in use") to allow
> address validation before changes are committed and to be able to
> fail the address change with an error back to the user. The address
> validation is not done for addresses received from router
> advertisements.
> 
> Handling RAs in softirq context is the only reason for the notifier
> chain to be atomic versus blocking. Since the only current user, ipvlan,
> of the validator chain ignores softirq context, the notifier can be made
> blocking and simply not invoked for softirq path.
> 
> The blocking option is needed by spectrum for example to validate
> resources for an adding an address to an interface.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

With the fixup posted later:

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

BTW, the in_softirq() check in ipvlan_addr6_validator_event() can be
removed after this patch.

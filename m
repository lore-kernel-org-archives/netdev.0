From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 2/5] net: ipv6: Make inet6addr_validator a
 blocking notifier
Date: Sun, 15 Oct 2017 10:53:47 +0300
Message-ID: <20171015075347.GB10604@shredder.mtl.com>
References: <1507935733-18950-1-git-send-email-dsahern@gmail.com>
 <1507935733-18950-3-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com, davem@davemloft.net,
        yoshfuji@linux-ipv6.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:49713 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750753AbdJOHxt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 03:53:49 -0400
Content-Disposition: inline
In-Reply-To: <1507935733-18950-3-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 04:02:10PM -0700, David Ahern wrote:
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

Thanks for taking care of the in_softirq() check.

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

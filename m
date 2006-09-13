From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/2] ethtool: allow const ethtool_ops
Date: Wed, 13 Sep 2006 14:09:48 +0900
Message-ID: <20060913140948.3b55d604@localhost.localdomain>
References: <20060908111613.12c1f9b8@localhost.localdomain>
	<4506DB63.2040904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:716 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030424AbWIMFKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 01:10:01 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4506DB63.2040904@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Sep 2006 12:08:03 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > The ethtool_ops structure is immutable, it expected to be setup
> > by the driver and is never changed. This patch allows drivers to
> > declare there ethtool_ops structure read-only.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> ACK, but I need the associated change-all-drivers patch, in order to 
> apply this.
> 
> 	Jeff
> 
> 

Actually, no driver is immediately required since this is valid:

exiting_driver.c:

static struct ethtool_ops myops= { ... };

static int mydriver_probe(...) {
...
	dev = alloc_etherdev(sizeof(struct mypriv));
...
	dev->ethtool_ops = &myops;
...
	return register_netdev(dev);
}

Remember difference between:
struct net_device {
 
	struct ethtool_ops *ethtool_ops;

Existing definition, allow network core to change contents of
dev->ethtool_ops.


	const struct ethtool_ops *ethtool_ops;
Proposed patch, network code treats dev->ethtool_ops contents
as read-only. Devices MAY make ethtool_ops const.

Radical change would be:
	struct ethtool_ops *const ethtool_ops;

This would mean every device would have to define ethtool_ops
as const. Devices MUST make ethtool_ops const.

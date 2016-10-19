From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 1/6] switchdev: Execute bridge ndos only for bridge
 ports
Date: Wed, 19 Oct 2016 11:00:05 -0400 (EDT)
Message-ID: <20161019.110005.2037777401331235347.davem@davemloft.net>
References: <1476809423-14624-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56308 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943233AbcJSPAI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 11:00:08 -0400
In-Reply-To: <1476809423-14624-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 18 Oct 2016 18:50:23 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> We recently got the following warning after setting up a vlan device on
> top of an offloaded bridge and executing 'bridge link':
...
> The problem is that the 8021q module propagates the call to
> ndo_bridge_getlink() via switchdev ops, but the switch driver doesn't
> recognize the netdev, as it's not offloaded.
> 
> While we can ignore calls being made to non-bridge ports inside the
> driver, a better fix would be to push this check up to the switchdev
> layer.
> 
> Note that these ndos can be called for non-bridged netdev, but this only
> happens in certain PF drivers which don't call the corresponding
> switchdev functions anyway.
> 
> Fixes: 99f44bb3527b ("mlxsw: spectrum: Enable L3 interfaces on top of bridge devices")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Tamir Winetroub <tamirw@mellanox.com>
> Tested-by: Tamir Winetroub <tamirw@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied and queued up for -stable, thanks.

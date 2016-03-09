From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 2/2] net: dsa: support
 SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF
Date: Wed, 9 Mar 2016 19:32:13 +0100
Message-ID: <20160309183213.GA18196@lunn.ch>
References: <1457545368-20647-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1457545368-20647-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	nikolay@cumulusnetworks.com, Elad Raz <eladr@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53492 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933584AbcCIScR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 13:32:17 -0500
Content-Disposition: inline
In-Reply-To: <1457545368-20647-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien

> -static bool dsa_slave_dev_check(struct net_device *dev)
> -{
> -	return dev->netdev_ops == &dsa_slave_netdev_ops;
> -}

Where is the equivalent of this happening? Where do we check that the
interface added to the bridge is part of the switch?

> -int dsa_slave_netdevice_event(struct notifier_block *unused,
> -			      unsigned long event, void *ptr)
> -{
> -	struct net_device *dev;
> -	int err = 0;
> -
> -	switch (event) {
> -	case NETDEV_CHANGEUPPER:
> -		dev = netdev_notifier_info_to_dev(ptr);
> -		if (!dsa_slave_dev_check(dev))
> -			goto out;
> -
> -		err = dsa_slave_master_changed(dev);
> -		if (err && err != -EOPNOTSUPP)
> -			netdev_warn(dev, "failed to reflect master change\n");
> -
> -		break;
> -	}
> -
> -out:
> -	return NOTIFY_DONE;
> -}

How about team/bonding? We are not ready to implement it yet with the
Marvell devices, but at some point we probably will. Won't we need the
events then? We need to know when a switch port has been added to a
team?

Or do you think a switchdev object will be added for this case?
Mellanox already have the ability to add switch interfaces to a team,
and then add the team to a bridge. So we need to ensure your solution
works for such stacked systems.

      Andrew

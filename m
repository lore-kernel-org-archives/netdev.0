From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH net-next 2/2] net: dsa: support SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF
Date: Wed, 09 Mar 2016 17:15:58 -0500
Message-ID: <87egbj2t7l.fsf@ketchup.mtl.sfl>
References: <1457545368-20647-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1457545368-20647-3-git-send-email-vivien.didelot@savoirfairelinux.com> <20160309183213.GA18196@lunn.ch> <20160309192413.GA2260@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Ido Schimmel <idosch@mellanox.com>,
	nikolay@cumulusnetworks.com, Elad Raz <eladr@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41653 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932065AbcCIWQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 17:16:06 -0500
In-Reply-To: <20160309192413.GA2260@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

Jiri Pirko <jiri@resnulli.us> writes:

> Wed, Mar 09, 2016 at 07:32:13PM CET, andrew@lunn.ch wrote:
>>Hi Vivien
>>
>>> -static bool dsa_slave_dev_check(struct net_device *dev)
>>> -{
>>> -	return dev->netdev_ops == &dsa_slave_netdev_ops;
>>> -}
>>
>>Where is the equivalent of this happening? Where do we check that the
>>interface added to the bridge is part of the switch?
>>
>>> -int dsa_slave_netdevice_event(struct notifier_block *unused,
>>> -			      unsigned long event, void *ptr)
>>> -{
>>> -	struct net_device *dev;
>>> -	int err = 0;
>>> -
>>> -	switch (event) {
>>> -	case NETDEV_CHANGEUPPER:
>>> -		dev = netdev_notifier_info_to_dev(ptr);
>>> -		if (!dsa_slave_dev_check(dev))
>>> -			goto out;
>>> -
>>> -		err = dsa_slave_master_changed(dev);
>>> -		if (err && err != -EOPNOTSUPP)
>>> -			netdev_warn(dev, "failed to reflect master change\n");
>>> -
>>> -		break;
>>> -	}
>>> -
>>> -out:
>>> -	return NOTIFY_DONE;
>>> -}
>>
>>How about team/bonding? We are not ready to implement it yet with the
>>Marvell devices, but at some point we probably will. Won't we need the
>>events then? We need to know when a switch port has been added to a
>>team?
>>
>>Or do you think a switchdev object will be added for this case?
>>Mellanox already have the ability to add switch interfaces to a team,
>>and then add the team to a bridge. So we need to ensure your solution
>>works for such stacked systems.
>
> I have to look at this more closer tomorrow, but I'm missing motivation
> behind this. Using existing notifiers, drivers can easily monitor what
> is going on with their uppers. Why do we need this to be changed?

Yes with notifiers, drivers can monitor these changes with the
NETDEV_CHANGEUPPER even. They can also forbid such bridging by returning
NOTIFY_BAD in the NETDEV_PRECHANGEUPPER event if I'm not mistaken.

But looking at DSA slave, Mellanox Spectrum, and Rocker, they all
implement this similar heavy code, while they could support a common
switchdev attribute and reduce boilerplate.

But maybe I'm wrong, what why I sent that as an RFC :-)

Thanks,
Vivien

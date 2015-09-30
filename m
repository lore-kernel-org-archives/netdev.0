From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net-next 0/6] net: switchdev: use specific
 switchdev_obj_*
Date: Wed, 30 Sep 2015 12:45:20 +0200
Message-ID: <20150930104520.GE2098@nanopsycho.orion>
References: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Sep 29, 2015 at 06:07:12PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>This patchset changes switchdev add, del, dump operations from this:
>
>    int     (*switchdev_port_obj_add)(struct net_device *dev,
>                                      struct switchdev_obj *obj,
>                                      struct switchdev_trans *trans);
>    int     (*switchdev_port_obj_del)(struct net_device *dev,
>                                      struct switchdev_obj *obj);
>    int     (*switchdev_port_obj_dump)(struct net_device *dev,
>                                      struct switchdev_obj *obj);
>
>to something similar to the notifier_call callback of a notifier_block:
>
>    int     (*switchdev_port_obj_add)(struct net_device *dev,
>                                      enum switchdev_obj_id id,
>                                      const void *obj,
>                                      struct switchdev_trans *trans);                                                             
>    int     (*switchdev_port_obj_del)(struct net_device *dev,
>                                      enum switchdev_obj_id id,
>                                      const void *obj);
>    int     (*switchdev_port_obj_dump)(struct net_device *dev,
>                                       enum switchdev_obj_id id, void *obj,
>                                       int (*cb)(void *obj));
>
>This allows the caller to pass and expect back a specific switchdev_obj_*
>structure (e.g. switchdev_obj_fdb) instead of the generic switchdev_obj one.
>
>This will simplify pushing the callback function down to the drivers.
>
>The first 3 patches get rid of the dev parameter of the dump callback, since it
>is not always neeeded (e.g. vlan_dump) and some drivers (such as DSA drivers)
>may not have easy access to it.
>
>Patches 4 and 5 implement the change in the switchdev operations and its users.
>
>Patch 6 extracts the inner switchdev_obj_* structures from switchdev_obj and
>removes this last one.


How about attrs? We should keep objs and attrs api consistent.

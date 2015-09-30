From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net-next 4/6] net: switchdev: pass callback to dump
 operation
Date: Wed, 30 Sep 2015 12:41:02 +0200
Message-ID: <20150930104102.GD2098@nanopsycho.orion>
References: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1443542838-19234-5-git-send-email-vivien.didelot@savoirfairelinux.com>
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
In-Reply-To: <1443542838-19234-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Sep 29, 2015 at 06:07:16PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Similar to the notifier_call callback of a notifier_block, change the
>function signature of switchdev dump operation to:
>
>    int switchdev_port_obj_dump(struct net_device *dev,
>                                enum switchdev_obj_id id, void *obj,
>                                int (*cb)(void *obj));
>
>This allows the caller to pass and expect back a specific
>switchdev_obj_* structure instead of the generic switchdev_obj one.
>
>Drivers implementation of dump operation can now expect this specific
>structure and call the callback with it. Drivers have been changed
>accordingly.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>---
> drivers/net/ethernet/rocker/rocker.c | 21 +++++++++--------
> include/net/switchdev.h              |  9 +++++---
> net/dsa/slave.c                      | 26 +++++++++++----------
> net/switchdev/switchdev.c            | 45 ++++++++++++++++++------------------
> 4 files changed, 53 insertions(+), 48 deletions(-)
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index 78fd443..107adb6 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -4538,10 +4538,10 @@ static int rocker_port_obj_del(struct net_device *dev,
> }
> 
> static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
>-				struct switchdev_obj *obj)
>+				struct switchdev_obj_fdb *fdb,
>+				int (*cb)(void *obj))

                                ^^^^^^^^^^^^^^^^^^^^ we should have some
				typedef for this.

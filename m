From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] mac80211: Supporting of IFLA_INFO_KIND rtnl attribute
Date: Sun, 7 Dec 2014 10:06:52 +0100
Message-ID: <88214C7B-ED89-4E9C-BB24-8F0187B88D5E@holtmann.org>
References: <1417910690-2021-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vadim Kochan <vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417910690-2021-1-git-send-email-vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Vadim,

> It allows to identify the wireless kind of device for
> the user application, e.g.:
> 
>    # ip -d link
> 
>    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
>        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 promiscuity 0
>    2: enp0s25: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 1000
>        link/ether XX:XX:XX:XX:XX:XX brd ff:ff:ff:ff:ff:ff promiscuity 0
>    3: wlp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
>        link/ether XX:XX:XX:XX:XX:XX brd ff:ff:ff:ff:ff:ff promiscuity 0
>        wireless
>    4: wlp0s26u1u2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>        link/ether XX:XX:XX:XX:XX:XX brd ff:ff:ff:ff:ff:ff promiscuity 0 
>        wireless 
> 
> Signed-off-by: Vadim Kochan <vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> net/mac80211/iface.c | 7 +++++++
> 1 file changed, 7 insertions(+)
> 
> diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
> index 653f5eb..b993c7d 100644
> --- a/net/mac80211/iface.c
> +++ b/net/mac80211/iface.c
> @@ -18,6 +18,7 @@
> #include <linux/rtnetlink.h>
> #include <net/mac80211.h>
> #include <net/ieee80211_radiotap.h>
> +#include <net/rtnetlink.h>
> #include "ieee80211_i.h"
> #include "sta_info.h"
> #include "debugfs_netdev.h"
> @@ -1624,6 +1625,10 @@ static void ieee80211_assign_perm_addr(struct ieee80211_local *local,
> 	mutex_unlock(&local->iflist_mtx);
> }
> 
> +static struct rtnl_link_ops wireless_link_ops __read_mostly = {
> +	.kind = "wireless",
> +};
> +

I would prefer if we use "wlan" here. Same as what we use for DEVTYPE and RFKILL switches. Being consistent across the kernel helps a lot. Since other subsystems including Bluetooth might want to identify their netdev as well and "wireless" would be just too generic.

Regards

Marcel

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

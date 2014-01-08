From: Rupesh Gujare <rupesh.gujare@atmel.com>
Subject: Re: [PATCH v3.6 08/19] ozwpan: slight optimization of addr compare
Date: Wed, 8 Jan 2014 16:04:43 +0000
Message-ID: <52CD771B.4030201@atmel.com>
References: <52CCBDB0.9060709@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<devel@driverdev.osuosl.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52CCBDB0.9060709@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/01/14 02:53, Ding Tianhong wrote:
> Use possibly more efficient ether_addr_equal
> instead of memcmp.
>
> Cc: Rupesh Gujare <rupesh.gujare@atmel.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: devel@driverdev.osuosl.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>   drivers/staging/ozwpan/ozcdev.c  | 2 +-
>   drivers/staging/ozwpan/ozproto.c | 5 +++--
>   2 files changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/staging/ozwpan/ozcdev.c b/drivers/staging/ozwpan/ozcdev.c
> index 6ce0af9..c363f66 100644
> --- a/drivers/staging/ozwpan/ozcdev.c
> +++ b/drivers/staging/ozwpan/ozcdev.c
> @@ -448,7 +448,7 @@ int oz_cdev_start(struct oz_pd *pd, int resume)
>   	}
>   	spin_lock(&g_cdev.lock);
>   	if ((g_cdev.active_pd == NULL) &&
> -		(memcmp(pd->mac_addr, g_cdev.active_addr, ETH_ALEN) == 0)) {
> +		ether_addr_equal(pd->mac_addr, g_cdev.active_addr)) {
>   		oz_pd_get(pd);
>   		g_cdev.active_pd = pd;
>   		oz_dbg(ON, "Active PD arrived\n");
> diff --git a/drivers/staging/ozwpan/ozproto.c b/drivers/staging/ozwpan/ozproto.c
> index 88714ec..19a2521 100644
> --- a/drivers/staging/ozwpan/ozproto.c
> +++ b/drivers/staging/ozwpan/ozproto.c
> @@ -9,6 +9,7 @@
>   #include <linux/timer.h>
>   #include <linux/sched.h>
>   #include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
>   #include <linux/errno.h>
>   #include <linux/ieee80211.h>
>   #include "ozdbg.h"
> @@ -180,7 +181,7 @@ static struct oz_pd *oz_connect_req(struct oz_pd *cur_pd, struct oz_elt *elt,
>   		spin_lock_bh(&g_polling_lock);
>   		list_for_each(e, &g_pd_list) {
>   			pd2 = container_of(e, struct oz_pd, link);
> -			if (memcmp(pd2->mac_addr, pd_addr, ETH_ALEN) == 0) {
> +			if (ether_addr_equal(pd2->mac_addr, pd_addr)) {
>   				free_pd = pd;
>   				pd = pd2;
>   				break;
> @@ -597,7 +598,7 @@ struct oz_pd *oz_pd_find(const u8 *mac_addr)
>   	spin_lock_bh(&g_polling_lock);
>   	list_for_each(e, &g_pd_list) {
>   		pd = container_of(e, struct oz_pd, link);
> -		if (memcmp(pd->mac_addr, mac_addr, ETH_ALEN) == 0) {
> +		if (ether_addr_equal(pd->mac_addr, mac_addr)) {
>   			atomic_inc(&pd->ref_count);
>   			spin_unlock_bh(&g_polling_lock);
>   			return pd;

Acked-by: Rupesh Gujare <rupesh.gujare@atmel.com>

Thanks,

-- 
Regards,
Rupesh Gujare

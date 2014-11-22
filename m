From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: eliminate banner[] variable and switch to pr_info()
Date: Sat, 22 Nov 2014 17:41:28 +0100
Message-ID: <5470BCB8.2090904@hartkopp.net>
References: <1416642155-31816-1-git-send-email-jmmahler@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeremiah Mahler <jmmahler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.221]:20712 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaKVQln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 11:41:43 -0500
In-Reply-To: <1416642155-31816-1-git-send-email-jmmahler@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.11.2014 08:42, Jeremiah Mahler wrote:
> Several CAN modules use a design pattern with a banner[] variable at the
> top which defines a string that is used once during init to print the
> banner.  The string is also embedded with KERN_INFO which makes it
> printk() specific.
>
> Improve the code by eliminating the banner[] variable and moving the
> string to where it is printed.  Then switch from printk(KERN_INFO to
> pr_info() for the lines that were changed.
>
> Signed-off-by: Jeremiah Mahler <jmmahler@gmail.com>

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Next time please only post on linux-can ML which is the first address for CAN 
related stuff - as long as you don't feel it's a networking relevant issue.

But for almost editorial changes - which is not urgent - linux-can should be 
enough.

Thanks,
Oliver


> ---
>   net/can/af_can.c | 5 +----
>   net/can/bcm.c    | 4 +---
>   net/can/raw.c    | 4 +---
>   3 files changed, 3 insertions(+), 10 deletions(-)
>
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index ce82337..ac05be1 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -64,9 +64,6 @@
>
>   #include "af_can.h"
>
> -static __initconst const char banner[] = KERN_INFO
> -	"can: controller area network core (" CAN_VERSION_STRING ")\n";
> -
>   MODULE_DESCRIPTION("Controller Area Network PF_CAN core");
>   MODULE_LICENSE("Dual BSD/GPL");
>   MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>, "
> @@ -896,7 +893,7 @@ static __init int can_init(void)
>   		     offsetof(struct can_frame, data) !=
>   		     offsetof(struct canfd_frame, data));
>
> -	printk(banner);
> +	pr_info("can: controller area network core (" CAN_VERSION_STRING ")\n");
>
>   	memset(&can_rx_alldev_list, 0, sizeof(can_rx_alldev_list));
>
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index dcb75c0..9aa3f76 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -78,8 +78,6 @@
>   		     (CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG))
>
>   #define CAN_BCM_VERSION CAN_VERSION
> -static __initconst const char banner[] = KERN_INFO
> -	"can: broadcast manager protocol (rev " CAN_BCM_VERSION " t)\n";
>
>   MODULE_DESCRIPTION("PF_CAN broadcast manager protocol");
>   MODULE_LICENSE("Dual BSD/GPL");
> @@ -1615,7 +1613,7 @@ static int __init bcm_module_init(void)
>   {
>   	int err;
>
> -	printk(banner);
> +	pr_info("can: broadcast manager protocol (rev " CAN_BCM_VERSION " t)\n");
>
>   	err = can_proto_register(&bcm_can_proto);
>   	if (err < 0) {
> diff --git a/net/can/raw.c b/net/can/raw.c
> index 081e81f..e3250e2 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -56,8 +56,6 @@
>   #include <net/net_namespace.h>
>
>   #define CAN_RAW_VERSION CAN_VERSION
> -static __initconst const char banner[] =
> -	KERN_INFO "can: raw protocol (rev " CAN_RAW_VERSION ")\n";
>
>   MODULE_DESCRIPTION("PF_CAN raw protocol");
>   MODULE_LICENSE("Dual BSD/GPL");
> @@ -810,7 +808,7 @@ static __init int raw_module_init(void)
>   {
>   	int err;
>
> -	printk(banner);
> +	pr_info("can: raw protocol (rev " CAN_RAW_VERSION ")\n");
>
>   	err = can_proto_register(&raw_can_proto);
>   	if (err < 0)
>

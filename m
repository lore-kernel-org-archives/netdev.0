From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3 v6] drivers: net: ethernet: qualcomm:
 rmnet: Initial implementation
Date: Mon, 21 Aug 2017 14:07:25 -0700 (PDT)
Message-ID: <20170821.140725.2042417771225949262.davem@davemloft.net>
References: <1503120931-30092-1-git-send-email-subashab@codeaurora.org>
        <1503120931-30092-4-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, dcbw@redhat.com,
        jiri@resnulli.us, stephen@networkplumber.org,
        David.Laight@ACULAB.COM, marcel@holtmann.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41620 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751575AbdHUVH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 17:07:26 -0400
In-Reply-To: <1503120931-30092-4-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Fri, 18 Aug 2017 23:35:31 -0600

> diff --git a/drivers/net/ethernet/qualcomm/Makefile b/drivers/net/ethernet/qualcomm/Makefile
> index 92fa7c4..c4f38bd 100644
> --- a/drivers/net/ethernet/qualcomm/Makefile
> +++ b/drivers/net/ethernet/qualcomm/Makefile
> @@ -9,3 +9,5 @@ obj-$(CONFIG_QCA7000_UART) += qcauart.o
>  qcauart-objs := qca_uart.o
>  
>  obj-y += emac/
> +
> +obj-$(CONFIG_RMNET) += rmnet/
> \ No newline at end of file

Missing final newline in this file.

> diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
> new file mode 100644
> index 0000000..5338bab
> --- /dev/null
> +++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
 ...
> +static inline int
> +rmnet_is_real_dev_registered(const struct net_device *real_dev)
> +{

Do not declare functions as inline in foo.c files, let the compiler decide.

> +static inline struct rmnet_real_dev_info*
> +__rmnet_get_real_dev_info(const struct net_device *real_dev)
> +{

Likewise.

> diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
> new file mode 100644
> index 0000000..f34fe9e
> --- /dev/null
> +++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
 ...
> +static inline void rmnet_set_skb_proto(struct sk_buff *skb)
> +{

Likewise.

> diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_main.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_main.c
> new file mode 100644
> index 0000000..80c3920
 ...
> +/* Startup/Shutdown */
> +
> +static int __init rmnet_init(void)
> +{
> +	rmnet_config_init();
> +	return 0;
> +}
> +
> +static void __exit rmnet_exit(void)
> +{
> +	rmnet_config_exit();
> +}
> +
> +module_init(rmnet_init)
> +module_exit(rmnet_exit)
> +MODULE_LICENSE("GPL v2");

Unless you intend to do something different here, having a completely separate foo.c file
just to invoke functions in another file at module init and exit time is wasteful.  Just
do the module_init()/module_exit() where the rmnet_config_{init,exit}() functions are.

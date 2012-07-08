From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch] bnx2x: Add run-time CNIC support
Date: Sun, 08 Jul 2012 03:31:22 -0700 (PDT)
Message-ID: <20120708.033122.2108511545126626834.davem@davemloft.net>
References: <1341740914-3181-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dmitry@broadcom.com
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48666 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272Ab2GHKbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2012 06:31:25 -0400
In-Reply-To: <1341740914-3181-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Sun, 8 Jul 2012 12:48:34 +0300

> This patch replaces the BCM_CNIC compilation flag with a run-time flag.
> This is mainly important for the SR-IOV driver, as this driver will share the
> same code with the PF/hypervisor driver. Since storage is not supported in
> SR-IOV (while is usually enabled in the non-SR-IOV driver), we don't want to
> waste resources on it.
> In addition this change makes the code prettier.
 ...
> -static const struct net_device_ops bnx2x_netdev_ops = {
> +static struct net_device_ops bnx2x_netdev_ops = {
 ...
> 
> +	if (CNIC_ENABLED(bp))
> +		bnx2x_netdev_ops.ndo_select_queue = bnx2x_select_queue;
> +#if defined(NETDEV_FCOE_WWNN)
> +	if (CNIC_ENABLED(bp))
> +		bnx2x_netdev_ops.ndo_fcoe_get_wwn = bnx2x_fcoe_get_wwn;
> +#endif
 ...
+static int set_is_cnic_enabled(void)
+{
+#if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
+	return 1;
+#else
+	return 0;
+#endif
+}

This is basically a joke.

You're losing const'ness of net_device_ops and other nice things for
what is still, in the end, set by kconfig options.

I'm not applying crap like this, sorry.

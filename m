From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 3/3 v5] drivers: net: ethernet: qualcomm:
 rmnet: Initial implementation
Date: Mon, 21 Aug 2017 21:08:53 -0700
Message-ID: <20170821210853.4b1a150d@xeon-e3>
References: <1502931307-517-1-git-send-email-subashab@codeaurora.org>
        <1502931307-517-4-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        David.Laight@ACULAB.COM, marcel@holtmann.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:32819 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdHVEJB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 00:09:01 -0400
Received: by mail-pf0-f179.google.com with SMTP id k3so1151445pfc.0
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 21:09:00 -0700 (PDT)
In-Reply-To: <1502931307-517-4-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +void rmnet_vnd_setup(struct net_device *rmnet_dev)
> +{
> +	struct rmnet_priv *priv;
> +
> +	/* Clear out private data */
> +	priv = netdev_priv(rmnet_dev);
> +	memset(priv, 0, sizeof(struct rmnet_priv));

Netdev private area is always zero on creation. See alloc_netdev().


> +struct rmnet_endpoint *rmnet_vnd_get_endpoint(struct net_device *rmnet_dev)
> +{
> +	struct rmnet_priv *priv;
> +
> +	if (!rmnet_dev)
> +		return 0;

Do not confuse 0 with NULL. Did you run sparse?

> +
> +	priv = netdev_priv(rmnet_dev);
> +	if (!priv)
> +		return 0;


netdev_priv() always returns a non-NULL value.  The private area is just
a constant offset below the original network_device structure.

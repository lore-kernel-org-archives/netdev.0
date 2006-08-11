From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 1/6] ehea: interface to network stack
Date: Sat, 12 Aug 2006 06:56:24 +1000
Message-ID: <20060811205624.GE479@krispykreme>
References: <44D99EFC.3000105@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53725 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S932418AbWHKU6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 16:58:46 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <44D99EFC.3000105@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

> --- linux-2.6.18-rc4-orig/drivers/net/ehea/ehea_main.c	1969-12-31 

> +#define DEB_PREFIX "main"

Doesnt appear to be used.

> +static struct net_device_stats *ehea_get_stats(struct net_device *dev)
...
> +	cb2 = kzalloc(H_CB_ALIGNMENT, GFP_KERNEL);

I cant see where this gets freed.

> +
> +				skb_index = ((index - i
> +					      + port_res->skb_arr_sq_len)
> +					     % port_res->skb_arr_sq_len);

This is going to force an expensive divide. Its much better to change
this to the simpler and quicker:

i++;
if (i > max)
	i = 0;

There are a few places in the driver can be changed to do this.

> +static int ehea_setup_single_port(struct ehea_adapter *adapter,A
> +				  int portnum, struct device_node *dn)
...
> +	cb4 = kzalloc(H_CB_ALIGNMENT, GFP_KERNEL);

I cant see where this is freed.

Anton

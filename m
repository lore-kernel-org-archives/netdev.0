From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Sun, 1 Nov 2009 11:19:54 -0800
Message-ID: <20091101111954.6cd2d569@nehalam>
References: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33986 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbZKATU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2009 14:20:28 -0500
In-Reply-To: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Too many configuration optons?

On Sat, 31 Oct 2009 22:03:14 -0700
Rasesh Mody <rmody@brocade.com> wrote:

> +
> +#ifdef BNAD_NO_IP_ALIGN
> +#define BNAD_NET_IP_ALIGN 0
> +#else
> +#define BNAD_NET_IP_ALIGN NET_IP_ALIGN
> +#endif
>

Why is this device special?



> +
> +
> +#define BNAD_TXQ_WI_NEEDED(_vectors)	(((_vectors) + 3) >> 2)
> +

Module parameters mean the hardware or the developer could not
decide how to do it right.  Please reduce or eliminate most of these.


> +static uint bnad_msix = 1;
> +module_param(bnad_msix, uint, 0444);
> +MODULE_PARM_DESC(bnad_msix, "Enable MSI-X");

If msi-X is available use it, if not then don't. User can handle
this globally with kernel command line option.

> +uint bnad_small_large_rxbufs = 1;
> +module_param(bnad_small_large_rxbufs, uint, 0444);
> +MODULE_PARM_DESC(bnad_small_large_rxbufs, "Enable small/large buffer receive");

Do or do not, please no config option.  The ideal case is:
  normal MTU == skb
  jumbo MTU = skb with fragmenets

> +static uint bnad_rxqsets_used;
> +module_param(bnad_rxqsets_used, uint, 0444);
> +MODULE_PARM_DESC(bnad_rxqsets_used, "Number of RxQ sets to be used");
> +
> +static uint bnad_ipid_mode;
> +module_param(bnad_ipid_mode, uint, 0444);
> +MODULE_PARM_DESC(bnad_ipid_mode, "0 - Use IP ID 0x0000 - 0x7FFF for LSO; "
> +    "1 - Use full range of IP ID for LSO");

Gack!


> +uint bnad_txq_depth = BNAD_ENTRIES_PER_TXQ;
> +module_param(bnad_txq_depth, uint, 0444);
> +MODULE_PARM_DESC(bnad_txq_depth, "Maximum number of entries per TxQ");

Should be ethtool configuration not module parameters

> +uint bnad_rxq_depth = BNAD_ENTRIES_PER_RXQ;
> +module_param(bnad_rxq_depth, uint, 0444);
> +MODULE_PARM_DESC(bnad_rxq_depth, "Maximum number of entries per RxQ");
> +
> +static uint bnad_vlan_strip = 1;
> +module_param(bnad_vlan_strip, uint, 0444);
> +MODULE_PARM_DESC(bnad_vlan_strip, "Let the hardware strip off VLAN header");

Just do VLAN acceleration.

> +static uint bnad_log_level = LOG_WARN_LEVEL;
> +module_param(bnad_log_level, uint, 0644);
> +MODULE_PARM_DESC(bnad_log_level, "Log level");

Use ethtool msg_level for this

> +static uint bnad_ioc_auto_recover = 1;
> +module_param(bnad_ioc_auto_recover, uint, 0644);
> +MODULE_PARM_DESC(bnad_ioc_auto_recover, "Enable auto recovery");

Why is this configurable?


-- 

From: Debashis Dutt <ddutt@Brocade.COM>
Subject: RE: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 2 Nov 2009 19:05:25 -0800
Message-ID: <1B6CC3D5ACAB014C8BFB6CB1CBD62CADD2835E982F@HQ-EXCH-7.corp.brocade.com>
References: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
 <20091101111954.6cd2d569@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:37343 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757675AbZKCDKb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 22:10:31 -0500
In-Reply-To: <20091101111954.6cd2d569@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen, 

Thanks for your feedback. Please 
see the responses inline.

Thanks

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
Sent: Sunday, November 01, 2009 11:20 AM
To: Rasesh Mody
Cc: netdev@vger.kernel.org; Adapter Linux Open SRC Team
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver

Too many configuration optons?
[Debashis] 
Yes, we are working on incorporating your feedback.

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
[Debashis] 
Will remove



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
[Debashis] 
Will address this.

> +static uint bnad_rxqsets_used;
> +module_param(bnad_rxqsets_used, uint, 0444);
> +MODULE_PARM_DESC(bnad_rxqsets_used, "Number of RxQ sets to be used");
> +
> +static uint bnad_ipid_mode;
> +module_param(bnad_ipid_mode, uint, 0444);
> +MODULE_PARM_DESC(bnad_ipid_mode, "0 - Use IP ID 0x0000 - 0x7FFF for LSO; "
> +    "1 - Use full range of IP ID for LSO");

Gack!
[Debashis] 
Will remove this


> +uint bnad_txq_depth = BNAD_ENTRIES_PER_TXQ;
> +module_param(bnad_txq_depth, uint, 0444);
> +MODULE_PARM_DESC(bnad_txq_depth, "Maximum number of entries per TxQ");

Should be ethtool configuration not module parameters
[Debashis] 
Yes, sure.

> +uint bnad_rxq_depth = BNAD_ENTRIES_PER_RXQ;
> +module_param(bnad_rxq_depth, uint, 0444);
> +MODULE_PARM_DESC(bnad_rxq_depth, "Maximum number of entries per RxQ");
> +
> +static uint bnad_vlan_strip = 1;
> +module_param(bnad_vlan_strip, uint, 0444);
> +MODULE_PARM_DESC(bnad_vlan_strip, "Let the hardware strip off VLAN header");

Just do VLAN acceleration.
[Debashis] 
Yes, sure

> +static uint bnad_log_level = LOG_WARN_LEVEL;
> +module_param(bnad_log_level, uint, 0644);
> +MODULE_PARM_DESC(bnad_log_level, "Log level");

Use ethtool msg_level for this
[Debashis] 
Will do.

> +static uint bnad_ioc_auto_recover = 1;
> +module_param(bnad_ioc_auto_recover, uint, 0644);
> +MODULE_PARM_DESC(bnad_ioc_auto_recover, "Enable auto recovery");

Why is this configurable?
[Debashis] 
Auto-recovery is used to recover automatically from a f/w failure. 
Disabling this helps preserve the state of the system/driver in case of a f/w failure

-- 

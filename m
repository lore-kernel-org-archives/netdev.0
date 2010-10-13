From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2.6.35-rc6] net-next: Add multiqueue support to vmxnet3
 driver
Date: Wed, 13 Oct 2010 14:57:32 -0700
Message-ID: <20101013145732.7d69d0f3@nehalam>
References: <alpine.LRH.2.00.1009290104130.464@sbhatewara-dev1.eng.vmware.com>
	<alpine.LRH.2.00.1010131445080.25989@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42156 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752970Ab0JMV5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 17:57:37 -0400
In-Reply-To: <alpine.LRH.2.00.1010131445080.25989@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Oct 2010 14:47:05 -0700 (PDT)
Shreyas Bhatewara <sbhatewara@vmware.com> wrote:

> #ifdef VMXNET3_RSS
> +static unsigned int num_rss_entries;
> +#define VMXNET3_MAX_DEVICES 10
> +
> +static int rss_ind_table[VMXNET3_MAX_DEVICES *
> +			 VMXNET3_RSS_IND_TABLE_SIZE + 1] = {
> +	[0 ... VMXNET3_MAX_DEVICES * VMXNET3_RSS_IND_TABLE_SIZE] = -1 };
> +#endif
> +static int num_tqs[VMXNET3_MAX_DEVICES + 1] = {
> +	[0 ... VMXNET3_MAX_DEVICES] = 1 };
> +static int num_rqs[VMXNET3_MAX_DEVICES + 1] = {
> +	[0 ... VMXNET3_MAX_DEVICES] = 1 };
> +static int share_tx_intr[VMXNET3_MAX_DEVICES + 1] = {
> +	[0 ... VMXNET3_MAX_DEVICES] = 0 };
> +static int buddy_intr[VMXNET3_MAX_DEVICES + 1] = {
> +	[0 ... VMXNET3_MAX_DEVICES] = 1 };
> +
> +static unsigned int num_adapters;
> +module_param_array(share_tx_intr, int, &num_adapters, 0400);
> +MODULE_PARM_DESC(share_tx_intr, "Share one IRQ among all tx queue completions. "
> +		 "Comma separated list of 1s and 0s - one for each NIC. "
> +		 "1 to share, 0 to not, default is 0");
> +module_param_array(buddy_intr, int, &num_adapters, 0400);
> +MODULE_PARM_DESC(buddy_intr, "Share one IRQ among corresponding tx and rx "
> +		 "queues. Comma separated list of 1s and 0s - one for each "
> +		 "NIC. 1 to share, 0 to not, default is 1");
> +module_param_array(num_tqs, int, &num_adapters, 0400);
> +MODULE_PARM_DESC(num_tqs, "Number of transmit queues in each adapter. Comma "
> +		 "separated list of integers. Setting this to 0 makes number"
> +		 " of queues same as number of CPUs. Default is 1.");
> +
> +#ifdef VMXNET3_RSS
> +module_param_array(rss_ind_table, int, &num_rss_entries, 0400);
> +MODULE_PARM_DESC(rss_ind_table, "RSS Indirection table. Number of entries "
> +		 "per NIC should be 32. Each integer in a comma separated list"
> +		 " is an rx queue number starting with 0. Repeat the same for"
> +		 " all NICs.");
> +module_param_array(num_rqs, int, &num_adapters, 0400);
> +MODULE_PARM_DESC(num_rqs, "Number of receive queues in each adapter. Comma "
> +		 " separated list of integers. Setting this to 0 makes number"
> +		 " of queues same as number of CPUs. Default is 1.");

Module parameters are not right for this. They lead to different API
for interacting with each driver vendor. Is there a another better API?
Does it have to be this tweakable in a production environment.

-- 

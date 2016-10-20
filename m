From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF
 support
Date: Thu, 20 Oct 2016 14:13:04 -0400 (EDT)
Message-ID: <20161020.141304.286994718471308700.davem@davemloft.net>
References: <1476942046-18789-1-git-send-email-rvatsavayi@caviumnetworks.com>
        <1476942046-18789-2-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@caviumnetworks.com,
        derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44058 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753336AbcJTSNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:13:06 -0400
In-Reply-To: <1476942046-18789-2-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Wed, 19 Oct 2016 22:40:38 -0700

> +/* Default behaviour of Liquidio is to provide one queue per VF. But Liquidio
> + * can also provide multiple queues to each VF. If user wants to change the
> + * default behaviour HW should be provided configuration info at init time,
> + * based on which it will create control queues for communicating with FW.
> + */
> +static u32 max_vfs[2] = { 0, 0 };
> +module_param_array(max_vfs, int, NULL, 0444);
> +MODULE_PARM_DESC(max_vfs, "Assign two comma-separated unsigned integers that specify max number of VFs for PF0 (left of the comma) and PF1 (right of the comma); for 23xx only. By default HW will configure as many VFs as queues after allocating PF queues.To increase queues for VF use this parameter. Use sysfs to create these VFs.");
> +
> +static unsigned int num_queues_per_pf[2] = { 0, 0 };
> +module_param_array(num_queues_per_pf, uint, NULL, 0444);
> +MODULE_PARM_DESC(num_queues_per_pf, "two comma-separated unsigned integers that specify number of queues per PF0 (left of the comma) and PF1 (right of the comma); for 23xx only");
> +
>  static int ptp_enable = 1;

We cannot continue to allow drivers to add custom module parameters to
control this.  It is the worst user experience possible.

We need a tree-wide generic, consistent, manner in which to configure
and control this kind of thing.

From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Thu, 17 Jul 2008 08:44:50 -0700
Message-ID: <20080717084450.42ceca96@extreme>
References: <12162854952457-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <jeff@garzik.org>, <yjwei@cn.fujitsu.com>, <rdreier@cisco.com>,
	<davem@davemloft.net>, <jcliburn@gmail.com>,
	<parag.warudkar@gmail.com>, <w@1wt.eu>,
	<oliver.schuster@schweigstill.de>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:53657 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754052AbYGQPow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 11:44:52 -0400
In-Reply-To: <12162854952457-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +/*
> + * atl1e_check_options - Range Checking for Command Line Parameters
> + * @adapter: board private structure
> + *
> + * This routine checks all command line parameters for valid user
> + * input.  If an invalid value is given, or if no user specified
> + * value exists, a default value is used.  The final value is stored
> + * in a variable in the adapter structure.
> + */
> +void __devinit atl1e_check_options(struct atl1e_adapter *adapter)
> +{
> +	struct pci_dev *pdev = adapter->pdev;
> +	int bd = adapter->bd_number;
> +	if (bd >= ATL1E_MAX_NIC) {
> +		dev_notice(&pdev->dev, "no configuration for board #%i\n", bd);
> +		dev_notice(&pdev->dev, "Using defaults for all values\n");
> +	}


The use of module parameters to set options is discouraged, especially
when there are better choices. All these parameter should be controllable by ethtool.
The reason is that users (and tools) shouldn't have to know the
special parameters that are specific to that hardware.

This version is okay as is for initial inclusion, but the parameters should
be removed later.

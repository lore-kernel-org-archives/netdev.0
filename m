From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: [PATCH] ixgb: add PCI Error recovery callbacks
Date: Mon, 03 Jul 2006 13:49:26 +0800
Message-ID: <1151905766.28493.129.camel@ymzhang-perf.sh.intel.com>
References: <20060629162634.GC5472@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"bibo,mao" <bibo.mao@intel.com>,
	Rajesh Shah <rajesh.shah@intel.com>,
	Grant Grundler <grundler@parisc-linux.org>, akpm@osdl.org,
	LKML <linux-kernel@vger.kernel.org>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:53592 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751351AbWGCFuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 01:50:54 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060629162634.GC5472@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-30 at 00:26, Linas Vepstas wrote:
> Adds PCI Error recovery callbacks to the Intel 10-gigabit ethernet
> ixgb device driver. Lightly tested, works.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> +/**
> + * ixgb_io_error_detected() - called when PCI error is detected
> + * @pdev    pointer to pci device with error
> + * @state   pci channel state after error
> + *
> + * This callback is called by the PCI subsystem whenever
> + * a PCI bus error is detected.
> + */
> +static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
> +			             enum pci_channel_state state)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct ixgb_adapter *adapter = netdev->priv;
> +
> +	if(netif_running(netdev))
> +		ixgb_down(adapter, TRUE);
> +
> +	pci_disable_device(pdev);
> +
> +	/* Request a slot reset. */
> +	return PCI_ERS_RESULT_NEED_RESET;
> +}
Both pci_disable_device and ixgb_down would access the device. It doesn't
follow Documentation/pci-error-recovery.txt that error_detected shouldn't do
any access to the device.

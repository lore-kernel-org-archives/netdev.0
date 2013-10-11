From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 1/9] qlcnic: Print informational messages
 only once during driver load.
Date: Fri, 11 Oct 2013 12:33:20 -0700
Message-ID: <1381520000.27498.21.camel@joe-AO722>
References: <cover.1381538863.git.himanshu.madhani@qlogic.com>
	 <8a3b95951fa6a48a8fa52975a567ead4c692a153.1381538863.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0189.hostedemail.com ([216.40.44.189]:32979 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752731Ab3JKTdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 15:33:23 -0400
In-Reply-To: <8a3b95951fa6a48a8fa52975a567ead4c692a153.1381538863.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-11 at 14:42 -0400, Himanshu Madhani wrote:
> From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

trivia:

> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
[]
> @@ -94,13 +94,30 @@ qlcnic_83xx_config_vnic_buff_descriptors(struct qlcnic_adapter *adapter)
[]
> +		for (i = 0; i < ahw->act_pci_func; i++, npar++) {
> +			dev_info(dev, "id = %d active = %d type = %d\n"
> +				 "\tport = %d min bw = %d max bw = %d\n"
> +				 "\tmac_addr =  %pM\n", npar->pci_func,
> +				 npar->active, npar->type, npar->phy_port,
> +				 npar->min_bw, npar->max_bw, npar->mac);

Only the first line in dmesg will be prefixed with device
information this way.  This can make it difficult to use
"$ grep qlcnic" dmesg easily.  It might be better to use
3 lines or just 1 line.

			dev_info(dev, "id = %d active = %d type = %d port = %d min bw = %d max bw = %d mac_addr = %pM\n",
				 npar->pci_func, npar->active, npar->type,
				 npar->phy_port, npar->min_bw, npar->max_bw,
				 npar->mac);

I'd've used colons to shorten it a bit too:

			dev_info(dev, "id:%d active:%d type:%d port:%d min_bw:%d max_bw:%d mac_addr:%pM\n",
				 npar->pci_func, npar->active, npar->type,
				 npar->phy_port, npar->min_bw, npar->max_bw,
				 npar->mac);

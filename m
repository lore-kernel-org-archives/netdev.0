From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 NEXT 6/8] qlcnic: sparse warning fixes
Date: Tue, 12 Apr 2011 00:00:01 +0100
Message-ID: <1302562801.5282.576.camel@localhost>
References: <1286205297-23214-1-git-send-email-amit.salecha@qlogic.com>
	 <1286205297-23214-6-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14473 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756290Ab1DKXAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 19:00:05 -0400
In-Reply-To: <1286205297-23214-6-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-04 at 08:14 -0700, Amit Kumar Salecha wrote:
> From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> 
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> ---
>  drivers/net/qlcnic/qlcnic_ctx.c  |   12 ++++++------
>  drivers/net/qlcnic/qlcnic_main.c |   10 +++++-----
>  2 files changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
> index a4c4d09..75e3b19 100644
> --- a/drivers/net/qlcnic/qlcnic_ctx.c
> +++ b/drivers/net/qlcnic/qlcnic_ctx.c
> @@ -742,15 +742,15 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
>  
>  	if (err == QLCNIC_RCODE_SUCCESS) {
>  		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++, pci_info++) {
> -			pci_info->id = le32_to_cpu(npar->id);
> -			pci_info->active = le32_to_cpu(npar->active);
> -			pci_info->type = le32_to_cpu(npar->type);
> +			pci_info->id = le16_to_cpu(npar->id);
> +			pci_info->active = le16_to_cpu(npar->active);
> +			pci_info->type = le16_to_cpu(npar->type);
>  			pci_info->default_port =
> -				le32_to_cpu(npar->default_port);
> +				le16_to_cpu(npar->default_port);
>  			pci_info->tx_min_bw =
> -				le32_to_cpu(npar->tx_min_bw);
> +				le16_to_cpu(npar->tx_min_bw);
>  			pci_info->tx_max_bw =
> -				le32_to_cpu(npar->tx_max_bw);
> +				le16_to_cpu(npar->tx_max_bw);
[...]

It looks like this function was broken on big-endian systems.  The
commit message should say that you are fixing a bug, not just that some
unspecified 'sparse warning[s]' (that alerted you to the bug) were
fixed.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


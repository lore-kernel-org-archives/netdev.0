From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 16/20] fm10k: check if PCIe link is restored
Date: Thu, 21 Jul 2016 13:51:54 +0300
Message-ID: <63e931a3-e447-5a1f-f998-578e1cb2eb8e@cogentembedded.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1469053438-85381-17-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:36025 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbcGUKv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 06:51:58 -0400
Received: by mail-lf0-f45.google.com with SMTP id g62so58228773lfe.3
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 03:51:57 -0700 (PDT)
In-Reply-To: <1469053438-85381-17-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/21/2016 1:23 AM, Jeff Kirsher wrote:

> From: Jacob Keller <jacob.e.keller@intel.com>
>
> Sometimes, a VF driver will lose PCIe address access, such as due to
> a PF FLR event. In fm10k_detach_subtask, poll and check whether the
> PCIe register space is active again and restore the device when it has.
>
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
> index 5e40460..d4ccb2a 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
> @@ -123,11 +123,24 @@ static void fm10k_service_timer(unsigned long data)
>  static void fm10k_detach_subtask(struct fm10k_intfc *interface)
>  {
>  	struct net_device *netdev = interface->netdev;
> +	u32 __iomem *hw_addr;
> +	u32 value;
>
>  	/* do nothing if device is still present or hw_addr is set */
>  	if (netif_device_present(netdev) || interface->hw.hw_addr)
>  		return;
>
> +	/* check the real address space to see if we've recovered */
> +	hw_addr = READ_ONCE(interface->uc_addr);
> +	value = readl(hw_addr);
> +	if ((~value)) {

    Why these double parens?

[...]

MBR, Sergei

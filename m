From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v3.16]r8169: Remove unsupported command on pci express
Date: Fri, 11 Mar 2016 22:10:37 +0300
Message-ID: <56E3182D.6050107@cogentembedded.com>
References: <1457708793-1805-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: Corcodel Marian <asd@marian1000.go.ro>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:34607 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbcCKTKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:10:41 -0500
Received: by mail-lb0-f182.google.com with SMTP id xr8so163004680lbb.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 11:10:40 -0800 (PST)
In-Reply-To: <1457708793-1805-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/11/2016 06:06 PM, Corcodel Marian wrote:

>   On pci express not support latency timer.For more info read file /drivers/pci/pci.c
>   on pcibios_set_master function.
>
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> ---
>   drivers/net/ethernet/realtek/r8169.c | 10 +++++++---
>   1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 41750df..02aec96 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -753,6 +753,7 @@ struct rtl8169_private {
>   	struct ring_info tx_skb[NUM_TX_DESC];	/* Tx data buffers */
>   	struct timer_list timer;
>   	u16 cp_cmd;
> +	bool pcie;
>
>   	u16 event_slow;
>
> @@ -3757,8 +3758,8 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
>   		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
>   		RTL_W8(0x82, 0x01);
>   	}
> -
> -	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
> +	if (tp->pcie == 0)

    Haven't you just declared this field as *bool*?

> +		pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
>
>   	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
>   		pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 0x08);
> @@ -7083,8 +7084,11 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>   	}
>   	tp->mmio_addr = ioaddr;
>
> -	if (!pci_is_pcie(pdev))
> +	if (!pci_is_pcie(pdev)) {
>   		netif_info(tp, probe, dev, "not PCI Express\n");
> +		tp->pcie = 0;
> +	} else
> +		tp->pcie = 1;

    Same question, you should assign true/false.

[...]

MBR, Sergei

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH 2/3] ssb: provide phy address for Gigabit Ethernet
 driver
Date: Tue, 1 Oct 2013 14:13:19 -0700
Message-ID: <524B3AEF.9060109@broadcom.com>
References: <1380402928-11480-1-git-send-email-hauke@hauke-m.de>
 <1380402928-11480-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mchan@broadcom.com, netdev@vger.kernel.org
To: "Hauke Mehrtens" <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2544 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444Ab3JAVOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 17:14:19 -0400
In-Reply-To: <1380402928-11480-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/28/2013 02:15 PM, Hauke Mehrtens wrote:
> Add a function to provide the phy address which should be used to the
> Gigabit Ethernet driver connected to ssb.
>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---

Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>


>   include/linux/ssb/ssb_driver_gige.h |   14 ++++++++++++++
>   1 file changed, 14 insertions(+)
>
> diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
> index 86a12b0..0688472 100644
> --- a/include/linux/ssb/ssb_driver_gige.h
> +++ b/include/linux/ssb/ssb_driver_gige.h
> @@ -108,6 +108,16 @@ static inline int ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
>   	return 0;
>   }
>
> +/* Get the device phy address */
> +static inline int ssb_gige_get_phyaddr(struct pci_dev *pdev)
> +{
> +	struct ssb_gige *dev = pdev_to_ssb_gige(pdev);
> +	if (!dev)
> +		return -ENODEV;
> +
> +	return dev->dev->bus->sprom.et0phyaddr;
> +}
> +
>   extern int ssb_gige_pcibios_plat_dev_init(struct ssb_device *sdev,
>   					  struct pci_dev *pdev);
>   extern int ssb_gige_map_irq(struct ssb_device *sdev,
> @@ -174,6 +184,10 @@ static inline int ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
>   {
>   	return -ENODEV;
>   }
> +static inline int ssb_gige_get_phyaddr(struct pci_dev *pdev)
> +{
> +	return -ENODEV;
> +}
>
>   #endif /* CONFIG_SSB_DRIVER_GIGE */
>   #endif /* LINUX_SSB_DRIVER_GIGE_H_ */
>

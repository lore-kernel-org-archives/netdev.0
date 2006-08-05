From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH wireless-dev] Use IRQF_SHARED instead of SA_SHIRQ
Date: Sat, 5 Aug 2006 12:37:36 +0200
Message-ID: <200608051237.36995.mb@bu3sch.de>
References: <200608050057.09787.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:8080
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1161162AbWHEKjH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 06:39:07 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200608050057.09787.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 05 August 2006 09:57, Michael Wu wrote:
> Use IRQF_SHARED instead of SA_SHIRQ
> 
> This patch switches all instances of SA_SHIRQ to IRQF_SHARED for drivers in 
> the drivers/net/wireless/d80211 directory. According to 
> feature-removal-schedule.txt, the interrupt related SA_* flags are obsolete 
> and should be replaced by the appropriate IRQF_* version before January 2007.
> 
> Signed-off-by: Michael Wu <flamingice@sourmilk.net>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Are you also planning to do such a patch against softmac-bcm43xx? (Mainline)

> ---
> 
>  drivers/net/wireless/d80211/adm8211/adm8211.c      |    2 +-
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    2 +-
>  drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |    2 +-
>  drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |    2 +-
>  drivers/net/wireless/d80211/rt2x00/rt61pci.c       |    2 +-
>  5 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c 
> b/drivers/net/wireless/d80211/adm8211/adm8211.c
> index 339b69c..dcabeab 100644
> --- a/drivers/net/wireless/d80211/adm8211/adm8211.c
> +++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
> @@ -1627,7 +1627,7 @@ static int adm8211_open(struct net_devic
>  	adm8211_rf_set_channel(dev, priv->channel);
>  
>  	retval = request_irq(dev->irq, &adm8211_interrupt,
> -			     SA_SHIRQ, dev->name, dev);
> +			     IRQF_SHARED, dev->name, dev);
>  	if (retval) {
>  		printk(KERN_ERR "%s: failed to register IRQ handler\n",
>  		       dev->name);
> diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c 
> b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> index 59d137b..6366020 100644
> --- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> +++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> @@ -2295,7 +2295,7 @@ #ifdef CONFIG_BCM947XX
>  	}
>  #endif
>  	err = request_irq(bcm->irq, bcm43xx_interrupt_handler,
> -			  SA_SHIRQ, KBUILD_MODNAME, bcm);
> +			  IRQF_SHARED, KBUILD_MODNAME, bcm);
>  	if (err)
>  		printk(KERN_ERR PFX "Cannot register IRQ%d\n", bcm->irq);
>  
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
> b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> index 709cdbf..16e78b9 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> +++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> @@ -1356,7 +1356,7 @@ static int rt2400pci_initialize(struct r
>  	 * Register interrupt handler.
>  	 */
>  	if (request_irq(rt2x00dev_pci(rt2x00dev)->irq, rt2400pci_interrupt,
> -		SA_SHIRQ, net_dev->name, rt2x00dev)) {
> +		IRQF_SHARED, net_dev->name, rt2x00dev)) {
>  		ERROR("IRQ %d allocation failed.\n",
>  			rt2x00dev_pci(rt2x00dev)->irq);
>  		goto exit_fail;
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
> b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> index 8a22968..f79d386 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> +++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> @@ -1476,7 +1476,7 @@ static int rt2500pci_initialize(struct r
>  	 * Register interrupt handler.
>  	 */
>  	if (request_irq(rt2x00dev_pci(rt2x00dev)->irq, rt2500pci_interrupt,
> -		SA_SHIRQ, net_dev->name, rt2x00dev)) {
> +		IRQF_SHARED, net_dev->name, rt2x00dev)) {
>  		ERROR("IRQ %d allocation failed.\n",
>  			rt2x00dev_pci(rt2x00dev)->irq);
>  		goto exit_fail;
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
> b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> index 8bb9de9..b28e113 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> +++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> @@ -1902,7 +1902,7 @@ static int rt61pci_initialize(struct rt2
>  	 * Register interrupt handler.
>  	 */
>  	if (request_irq(rt2x00dev_pci(rt2x00dev)->irq, rt61pci_interrupt,
> -		SA_SHIRQ, net_dev->name, rt2x00dev)) {
> +		IRQF_SHARED, net_dev->name, rt2x00dev)) {
>  		ERROR("IRQ %d allocation failed.\n",
>  			rt2x00dev_pci(rt2x00dev)->irq);
>  		goto exit_fail;
> 

-- 
Greetings Michael.

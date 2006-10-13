From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH wireless-dev] Remove struct pt_regs * from d80211 drivers
Date: Fri, 13 Oct 2006 22:40:17 +0200
Message-ID: <200610132240.17425.mb@bu3sch.de>
References: <200610131601.54254.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:26293
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751885AbWJMUkr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 16:40:47 -0400
To: John Linville <linville@tuxdriver.com>
In-Reply-To: <200610131601.54254.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 13 October 2006 22:01, Michael Wu wrote:
> Remove struct pt_regs * from d80211 drivers
> 
> This patch will be necessary once wireless-dev pulls the 2.6.19-rc2 changes 
> which include the removal of the struct pt_regs * argument in interrupt 
> handler callbacks. Thanks to Johannes Berg <johannes@sipsolutions.net> for 
> finding a spot in the bcm43xx driver that called the irq handler manually.
> 
> Signed-off-by: Michael Wu <flamingice@sourmilk.net>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

> ---
> 
>  drivers/net/wireless/d80211/adm8211/adm8211.c      |    3 +--
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    4 ++--
>  drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |    3 +--
>  drivers/net/wireless/d80211/rt2x00/rt2400pci.h     |    3 +--
>  drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |    3 +--
>  drivers/net/wireless/d80211/rt2x00/rt2500pci.h     |    3 +--
>  drivers/net/wireless/d80211/rt2x00/rt2500usb.c     |    2 +-
>  drivers/net/wireless/d80211/rt2x00/rt2500usb.h     |    2 +-
>  drivers/net/wireless/d80211/rt2x00/rt61pci.c       |    3 +--
>  drivers/net/wireless/d80211/rt2x00/rt61pci.h       |    3 +--
>  drivers/net/wireless/d80211/rt2x00/rt73usb.c       |    2 +-
>  drivers/net/wireless/d80211/rt2x00/rt73usb.h       |    2 +-
>  12 files changed, 13 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c 
> b/drivers/net/wireless/d80211/adm8211/adm8211.c
> index 5522e15..38d483a 100644
> --- a/drivers/net/wireless/d80211/adm8211/adm8211.c
> +++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
> @@ -568,8 +568,7 @@ static void adm8211_interrupt_rci(struct
>  }
>  
>  
> -static irqreturn_t adm8211_interrupt(int irq, void *dev_id,
> -				     struct pt_regs *regs)
> +static irqreturn_t adm8211_interrupt(int irq, void *dev_id)
>  {
>  #define ADM8211_INT(x) if (unlikely(stsr & ADM8211_STSR_ ## x)) 
> printk(KERN_DEBUG "%s: " #x "\n", dev->name)
>  
> diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c 
> b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> index 82f1fd1..2c8339b 100644
> --- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> +++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> @@ -1619,7 +1619,7 @@ static void bcm43xx_interrupt_ack(struct
>  }
>  
>  /* Interrupt handler top-half */
> -static irqreturn_t bcm43xx_interrupt_handler(int irq, void *dev_id, struct 
> pt_regs *regs)
> +static irqreturn_t bcm43xx_interrupt_handler(int irq, void *dev_id)
>  {
>  	irqreturn_t ret = IRQ_HANDLED;
>  	struct bcm43xx_private *bcm = dev_id;
> @@ -3707,7 +3707,7 @@ static void bcm43xx_net_poll_controller(
>  
>  	local_irq_save(flags);
>  	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
> -		bcm43xx_interrupt_handler(bcm->irq, bcm, NULL);
> +		bcm43xx_interrupt_handler(bcm->irq, bcm);
>  	local_irq_restore(flags);
>  }
>  #endif /* CONFIG_NET_POLL_CONTROLLER */
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
> b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> index a46b8b8..bdc57fc 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> +++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> @@ -1803,8 +1803,7 @@ static void rt2400pci_txdone(void *data)
>  			entry->tx_status.control.queue);
>  }
>  
> -static irqreturn_t rt2400pci_interrupt(int irq, void *dev_instance,
> -	struct pt_regs *regs)
> +static irqreturn_t rt2400pci_interrupt(int irq, void *dev_instance)
>  {
>  	struct rt2x00_dev *rt2x00dev = dev_instance;
>  	u32 reg;
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.h 
> b/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
> index a991b59..c120a4f 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
> +++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
> @@ -943,7 +943,6 @@ static void rt2400pci_disable_radio(stru
>  static void rt2400pci_beacondone(void *data);
>  static void rt2400pci_rxdone(void *data);
>  static void rt2400pci_txdone(void *data);
> -static irqreturn_t rt2400pci_interrupt(int irq, void *dev_instance,
> -	struct pt_regs *regs);
> +static irqreturn_t rt2400pci_interrupt(int irq, void *dev_instance);
>  
>  #endif /* RT2400PCI_H */
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
> b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> index c08b076..d350935 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> +++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> @@ -1952,8 +1952,7 @@ static void rt2500pci_txdone(void *data)
>  			entry->tx_status.control.queue);
>  }
>  
> -static irqreturn_t rt2500pci_interrupt(int irq, void *dev_instance,
> -	struct pt_regs *regs)
> +static irqreturn_t rt2500pci_interrupt(int irq, void *dev_instance)
>  {
>  	struct rt2x00_dev *rt2x00dev = dev_instance;
>  	u32 reg;
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.h 
> b/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
> index fb44881..fe832d6 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
> +++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
> @@ -1204,7 +1204,6 @@ static void rt2500pci_disable_radio(stru
>  static void rt2500pci_beacondone(void *data);
>  static void rt2500pci_rxdone(void *data);
>  static void rt2500pci_txdone(void *data);
> -static irqreturn_t rt2500pci_interrupt(int irq, void *dev_instance,
> -	struct pt_regs *regs);
> +static irqreturn_t rt2500pci_interrupt(int irq, void *dev_instance);
>  
>  #endif /* RT2500PCI_H */
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
> b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
> index 5d119cd..4f7dacd 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
> +++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
> @@ -1733,7 +1733,7 @@ static void rt2500usb_txdone(void *data)
>  			entry->tx_status.control.queue);
>  }
>  
> -static void rt2500usb_interrupt(struct urb *urb, struct pt_regs *regs)
> +static void rt2500usb_interrupt(struct urb *urb)
>  {
>  	struct data_entry *entry = (struct data_entry*)urb->context;
>  	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.h 
> b/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
> index 7babcb6..cd8cad0 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
> +++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
> @@ -725,6 +725,6 @@ static void rt2500usb_disable_radio(stru
>  static void rt2500usb_beacondone(void *data);
>  static void rt2500usb_rxdone(void *data);
>  static void rt2500usb_txdone(void *data);
> -static void rt2500usb_interrupt(struct urb *urb, struct pt_regs *regs);
> +static void rt2500usb_interrupt(struct urb *urb);
>  
>  #endif /* RT2500USB_H */
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
> b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> index 3e1a702..3751e61 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> +++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> @@ -2439,8 +2439,7 @@ static void rt61pci_txdone(void *data)
>  		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
>  }
>  
> -static irqreturn_t rt61pci_interrupt(int irq, void *dev_instance,
> -	struct pt_regs *regs)
> +static irqreturn_t rt61pci_interrupt(int irq, void *dev_instance)
>  {
>  	struct rt2x00_dev *rt2x00dev = dev_instance;
>  	u32 reg;
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.h 
> b/drivers/net/wireless/d80211/rt2x00/rt61pci.h
> index 77b867d..9d1e6a3 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt61pci.h
> +++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.h
> @@ -1410,7 +1410,6 @@ static void rt61pci_disable_radio(struct
>  static void rt61pci_beacondone(void *data);
>  static void rt61pci_rxdone(void *data);
>  static void rt61pci_txdone(void *data);
> -static irqreturn_t rt61pci_interrupt(int irq, void *dev_instance,
> -	struct pt_regs *regs);
> +static irqreturn_t rt61pci_interrupt(int irq, void *dev_instance);
>  
>  #endif /* RT61PCI_H */
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
> b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
> index a3b0996..72da71b 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
> +++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
> @@ -2025,7 +2025,7 @@ static void rt73usb_txdone(void *data)
>  			entry->tx_status.control.queue);
>  }
>  
> -static void rt73usb_interrupt(struct urb *urb, struct pt_regs *regs)
> +static void rt73usb_interrupt(struct urb *urb)
>  {
>  	struct data_entry *entry = (struct data_entry*)urb->context;
>  	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(
> diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.h 
> b/drivers/net/wireless/d80211/rt2x00/rt73usb.h
> index cc1013c..257dc7b 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt73usb.h
> +++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.h
> @@ -989,6 +989,6 @@ static void rt73usb_disable_radio(struct
>  static void rt73usb_beacondone(void *data);
>  static void rt73usb_rxdone(void *data);
>  static void rt73usb_txdone(void *data);
> -static void rt73usb_interrupt(struct urb *urb, struct pt_regs *regs);
> +static void rt73usb_interrupt(struct urb *urb);
>  
>  #endif /* RT73USB_H */
> 

-- 
Greetings Michael.

From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [Rt2400-devel] [PATCH 4/4] rt2x00-d80211: Add wireless statistics (compile tested only)
Date: Thu, 2 Nov 2006 20:10:30 +0100
Message-ID: <200611022010.30463.IvDoorn@gmail.com>
References: <454A3D6B.mail4SV1NEUKH@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	John Linville <linville@tuxdriver.com>,
	flamingice@sourmilk.net, Stefano Brivio <st3@riseup.net>,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:6013 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1752267AbWKBTKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 14:10:37 -0500
Received: by nf-out-0910.google.com with SMTP id o60so1006803nfa
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2006 11:10:36 -0800 (PST)
To: rt2400-devel@lists.sourceforge.net
In-Reply-To: <454A3D6B.mail4SV1NEUKH@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 02 November 2006 19:48, Larry Finger wrote:
> These patches modify the rt2x00-d80211 family of drivers to use
> the wireless statics added in patch 1.
> 
> Signed-Off-By: Larry Finger@lwfinger.net>

I will put the search for the correct values on my TODO list,
but that needs some heavy legacy driver research.
But these values seem sane enough for me. ;)

Signed-Off-By: Ivo van Doorn <IvDoorn@gmail.com>

> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> @@ -1695,6 +1695,14 @@ static void rt2400pci_rxdone(void *data)
>  			rt2x00dev->rx_params.ssi =
>  				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
>  
> +/* FIXME: The following set of assignments supply additional data for wireless statistics. The
> +          necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
> +          The present code supplies dummy values for these quantities. */
> +
> +			rt2x00dev->rx_params.noise = -85;   /* FIXME */
> +			rt2x00dev->rx_params.signal =
> +				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
> +
>  			__ieee80211_rx(ring->net_dev,
>  				skb, &rt2x00dev->rx_params);
>  		}
> @@ -2581,6 +2589,7 @@ static int rt2400pci_init_hw(struct rt2x
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 1;
>  	hw->fraglist = 0;
> +	hw->maxssi = RT2X00_RX_MAX_SSI;
>  
>  	/*
>  	 * We have 2 TX queues: TX and PRIO.
> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> @@ -1841,6 +1841,14 @@ static void rt2500pci_rxdone(void *data)
>  			rt2x00dev->rx_params.ssi =
>  				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
>  
> +/* FIXME: The following set of assignments supply additional data for wireless statistics. The
> +          necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
> +          The present code supplies dummy values for these quantities. */
> +
> +			rt2x00dev->rx_params.noise = -85;   /* FIXME */
> +			rt2x00dev->rx_params.signal =
> +				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
> +
>  			__ieee80211_rx(ring->net_dev,
>  				skb, &rt2x00dev->rx_params);
>  
> @@ -2735,6 +2743,7 @@ static int rt2500pci_init_hw(struct rt2x
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 1;
>  	hw->fraglist = 0;
> +	hw->maxssi = RT2X00_RX_MAX_SSI;
>  
>  	/*
>  	 * We have 2 TX queues: TX and PRIO.
> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
> @@ -1627,6 +1627,14 @@ static void rt2500usb_rxdone(void *data)
>  			rt2x00dev->rx_params.ssi =
>  				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
>  
> +/* FIXME: The following set of assignments supply additional data for wireless statistics. The
> +	  necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
> +	  The present code supplies dummy values for these quantities. */
> +
> +			rt2x00dev->rx_params.noise = -85;   /* FIXME */
> +			rt2x00dev->rx_params.signal =
> +				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
> +
>  			__ieee80211_rx(ring->net_dev,
>  				skb, &rt2x00dev->rx_params);
>  
> @@ -2423,6 +2431,7 @@ static int rt2500usb_init_hw(struct rt2x
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 1;
>  	hw->fraglist = 0;
> +	hw->maxssi = RT2X00_RX_MAX_SSI;
>  
>  	/*
>  	 * We have 2 TX queues: TX and PRIO.
> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2x00.h
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2x00.h
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2x00.h
> @@ -850,6 +850,8 @@ struct rt2x00_dev {
>  #define CONFIG_DOUBLE_ANTENNA		0x00010000
>  #define CONFIG_DISABLE_BBP_TUNING	0x00020000
>  
> +#define RT2X00_RX_MAX_SSI		100
> +
>  	/*
>  	 * Chipset identification.
>  	 */
> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> @@ -2285,6 +2285,14 @@ static void rt61pci_rxdone(void *data)
>  			rt2x00dev->rx_params.ssi =
>  				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
>  
> +/* FIXME: The following set of assignments supply additional data for wireless statistics. The
> +	  necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
> +	  The present code supplies dummy values for these quantities. */
> +
> +			rt2x00dev->rx_params.noise = -85;   /* FIXME */
> +			rt2x00dev->rx_params.signal =
> +				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
> +
>  			__ieee80211_rx(ring->net_dev,
>  				skb, &rt2x00dev->rx_params);
>  
> @@ -3255,6 +3263,7 @@ static int rt61pci_init_hw(struct rt2x00
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 1;
>  	hw->fraglist = 0;
> +	hw->maxssi = RT2X00_RX_MAX_SSI;
>  
>  	/*
>  	 * We have full WMM capabilities.
> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
> @@ -1917,6 +1917,14 @@ static void rt73usb_rxdone(void *data)
>  			rt2x00dev->rx_params.ssi =
>  				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
>  
> +/* FIXME: The following set of assignments supply additional data for wireless statistics. The
> +	  necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
> +	  The present code supplies dummy values for these quantities. */
> +
> +			rt2x00dev->rx_params.noise = -85;   /* FIXME */
> +			rt2x00dev->rx_params.signal =
> +				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
> +
>  			__ieee80211_rx(ring->net_dev,
>  				skb, &rt2x00dev->rx_params);
>  
> @@ -2796,6 +2804,7 @@ static int rt73usb_init_hw(struct rt2x00
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 1;
>  	hw->fraglist = 0;
> +	hw->maxssi = RT2X00_RX_MAX_SSI;
>  
>  	/*
>  	 * We have full WMM capabilities.
> 
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> Rt2400-devel mailing list
> Rt2400-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/rt2400-devel
> 

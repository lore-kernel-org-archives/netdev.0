From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 5/10] rt2x00: Register initialization fixes
Date: Mon, 28 Aug 2006 12:08:39 -0400
Message-ID: <20060828160834.GA14069@tuxdriver.com>
References: <200608271739.14166.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:31506 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751145AbWH1QJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 12:09:16 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200608271739.14166.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 27, 2006 at 05:39:14PM +0200, Ivo van Doorn wrote:
> Various register initialization fixes to make the device work properly.
> This will fix the RX/TX issue for rt61pci.
> 
> Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>
> 
> ---
> 
> diff -rU3 wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> --- wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:11:40.000000000 +0200
> +++ wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:17:02.000000000 +0200
> @@ -1192,11 +1192,7 @@
>  	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
>  
>  	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00217223));
> -
> -	rt2x00_register_read(rt2x00dev, MACCSR1, &reg);
> -	rt2x00_set_field32(&reg, MACCSR1_AUTO_TXBBP, 1);
> -	rt2x00_set_field32(&reg, MACCSR1_AUTO_RXBBP, 1);
> -	rt2x00_register_write(rt2x00dev, MACCSR1, reg);
> +	rt2x00_register_write(rt2x00dev, MACCSR1, cpu_to_le32(0x00235518));
>  
>  	rt2x00_register_read(rt2x00dev, MACCSR2, &reg);
>  	rt2x00_set_field32(&reg, MACCSR2_DELAY, 64);
> diff -rU3 wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> --- wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:12:03.000000000 +0200
> +++ wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:17:56.000000000 +0200
> @@ -1249,6 +1249,7 @@
>  		return -EBUSY;
>  
>  	rt2x00_register_write(rt2x00dev, PWRCSR0, cpu_to_le32(0x3f3b3100));
> +	rt2x00_register_write(rt2x00dev, PCICSR, cpu_to_le32(0x000003b8));
>  
>  	rt2x00_register_write(rt2x00dev, PSCSR0, cpu_to_le32(0x00020002));
>  	rt2x00_register_write(rt2x00dev, PSCSR1, cpu_to_le32(0x00000002));
> @@ -1272,12 +1273,11 @@
>  	rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
>  	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
>  
> -	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00213223));
> +	rt2x00_register_write(rt2x00dev, GPIOCSR, cpu_to_le32(0x0000ff00));
> +	rt2x00_register_write(rt2x00dev, TESTCSR, cpu_to_le32(0x000000f0));
>  
> -	rt2x00_register_read(rt2x00dev, MACCSR1, &reg);
> -	rt2x00_set_field32(&reg, MACCSR1_AUTO_TXBBP, 1);
> -	rt2x00_set_field32(&reg, MACCSR1_AUTO_RXBBP, 1);
> -	rt2x00_register_write(rt2x00dev, MACCSR1, reg);
> +	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00213223));
> +	rt2x00_register_write(rt2x00dev, MACCSR1, cpu_to_le32(0x00235518));
>  
>  	rt2x00_register_read(rt2x00dev, MACCSR2, &reg);
>  	rt2x00_set_field32(&reg, MACCSR2_DELAY, 64);

Lots of magic numbers here...can we do something about that?

John
-- 
John W. Linville
linville@tuxdriver.com

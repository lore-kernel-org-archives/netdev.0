From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH try#2] Blackfin ethernet driver: on chip ethernet MAC controller driver
Date: Sun, 15 Jul 2007 12:36:51 +0200
Message-ID: <200707151236.51779.mb@bu3sch.de>
References: <1184491629.3140.59.camel@roc-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier.adi@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: bryan.wu@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54421
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756864AbXGOKiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 06:38:15 -0400
In-Reply-To: <1184491629.3140.59.camel@roc-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 15 July 2007 11:27:09 Bryan Wu wrote:
> +#if defined(CONFIG_BFIN_MAC_USE_L1)
> +# define bfin_mac_alloc(dma_handle, size)  l1_data_sram_zalloc(size)
> +# define bfin_mac_free(dma_handle, ptr)    l1_data_sram_free(ptr)
> +#else
> +# define bfin_mac_alloc(dma_handle, size) \
> +	 dma_alloc_coherent(NULL, size, dma_handle, GFP_NORMAL)

What is GFP_NORMAL? It's not defined in latest linus' tree.
I think you should use GFP_KERNEL, if you can sleep, or GFP_ATOMIC,
if you can't.

The rest looks OK. Except the endianess issues. It might be no
issue on the hardware this runs on, but in favour of "clean code"
you might use leXX_to_cpu and friends anyway. :)
This kind of bugs is done so often, even in places where it _does_
matter. So, at least for the human reader, the leXX_to_cpu stuff
says that you really understood what you were doing when writing
the code. The current code says (to me), that it works by
accident, somehow, although it seems you knew what you were doing. :)

-- 
Greetings Michael.

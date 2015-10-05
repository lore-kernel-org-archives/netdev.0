From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 0/5] Improve ASIX RX memory allocation error handling
Date: Mon, 05 Oct 2015 06:59:20 -0700 (PDT)
Message-ID: <20151005.065920.245210984562951592.davem@davemloft.net>
References: <1443792548-2025-1-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org,
	linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org, Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org
To: Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443792548-2025-1-git-send-email-Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Date: Fri, 2 Oct 2015 14:29:03 +0100

> The ASIX RX handler algorithm is weak on error handling.
> There is a design flaw in the ASIX RX handler algorithm because the
> implementation for handling RX Ethernet frames for the DUB-E100 C1 can
> have Ethernet frames spanning multiple URBs. This means that payload data
> from more than 1 URB is sometimes needed to fill the socket buffer with a
> complete Ethernet frame. When the URB with the start of an Ethernet frame
> is received then an attempt is made to allocate a socket buffer. If the
> memory allocation fails then the algorithm sets the buffer pointer member
> to NULL and the function exits (no crash yet). Subsequently, the RX hander
> is called again to process the next URB which assumes there is a socket
> buffer available and the kernel crashes when there is no buffer.
> 
> This patchset implements an improvement to the RX handling algorithm to
> avoid a crash when no memory is available for the socket buffer.
> 
> The patchset will apply cleanly to the net-next master branch but the
> created kernel has not been tested. The driver was tested on ARM kernels
> v3.8 and v3.14 for a commercial product.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

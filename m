From: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
Subject: Re: [PATCH] net/usb: rtl8150: allocate URB transfer_buffer and setup_packet
 separately
Date: Thu, 08 Aug 2013 22:43:16 +0300
Message-ID: <5203F4D4.8090609@iki.fi>
References: <20130807133653.15587.35442.stgit@localhost6.localdomain6> <alpine.DEB.2.10.1308081809120.4258@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.10.1308081809120.4258-WOI+tvYbpdBn9MRfDTB0XAC/G2K4zDHf@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08.08.2013 18:14, Petko Manolov wrote:
> On Wed, 7 Aug 2013, Jussi Kivilinna wrote:
> 
>> rtl8150 allocates URB transfer_buffer and setup_packet as part of same 
>> structure 'struct async_req'. This can cause same cacheline to be 
>> DMA-mapped twice with same URB. This can lead to memory corruption on 
>> some systems.
> 
> I can see performance impact due to the double mapping.  However, memory 
> corruption seems a bit too much for sane cache and DMA controllers.  Out 
> of interest - which is the architecture that will potentially corrupt the 
> memory.

rtlwifi driver had similar structure to allocate both setup_packet and transfer_buffer in single go (overlapping dma-mapping cachelines) and this caused problems on ARM/sunxi. Problems means: memory corruptions at random locations, device freezes and lock-ups.

-Jussi

> 
> 
> cheers,
> Petko
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

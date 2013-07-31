From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports
 sg dma
Date: Wed, 31 Jul 2013 08:15:11 -0700
Message-ID: <1375283711.10515.104.camel@edumazet-glaptop>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	 <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	 <20130731124707.GA30635@kroah.com>
	 <CACVXFVNk+h7kBWTFT2NiGy+2F6LPatda3oL9+uuaQnT-u5J8wg@mail.gmail.com>
	 <1375279366.14846.1.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375279366.14846.1.camel-B2T3B9s34ElbnMAlSieJcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-31 at 16:02 +0200, Oliver Neukum wrote:
> On Wed, 2013-07-31 at 21:50 +0800, Ming Lei wrote:
> 
> > In the usbnet case, the driver already supports non-sg well. Actually,
> > all current drivers should support non-sg well because urb->sg wasn't
> > introduced for very long time. We can think it as a new feature or DMA
> > enhancement for xHCI controller.
> > 
> > If you mean buffer debounce for dma sg support on ehci/uhci/ohci/..,
> > maybe we need to discuss and evaluate further.
> 
> We cannot lie to the networking layer. Either we can do sg in hardware
> or we cannot. This is unfortunately determined by the HC not the device
> on the bus. How else but from the host driver would we get the
> information?
> 

Hmm, I would rather make sure SG is really supported before adding TSO
support.

TCP stack can build skb with fragments of any size, not multiple
of 512 or 1024 bytes.

commit 20f0170377264e8449b6987041f0bcc4d746d3ed

    usbnet: do not pretend to support SG/TSO
    
    usbnet doesn't support yet SG, so drivers should not advertise SG or TSO
    capabilities, as they allow TCP stack to build large TSO packets that
    need to be linearized and might use order-5 pages.
    
    This adds an extra copy overhead and possible allocation failures.
    
    Current code ignore skb_linearize() return code so crashes are even
    possible.
    
    Best is to not pretend SG/TSO is supported, and add this again when/if
    usbnet really supports SG for devices who could get a performance gain.
    


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

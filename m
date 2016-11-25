From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 25 Nov 2016 01:27:02 +0100
Message-ID: <20161125002702.GA14085@electric-eye.fr.zoreil.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
 <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <c3ca9e10-64de-2454-b99a-19e8302f5c12-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org> :
[...]
> >From tracing through the powerpc arch code, this is the buffer that
> is being directly DMA'd into.  And the USB layer does an invalidate_dcache
> on that entire buffer before initiating the DMA (confirmed via printk).
> 
> The driver itself NEVER writes anything to that buffer,
> and nobody else has a pointer to it other than the USB host controller,
> so there's nothing else that can write to it either.
> 
> According to the driver writer, the chip should only ever write a fresh
> rx_desc struct at the beginning of a buffer, never ASCII data.
> 
> So how does that buffer end up containing ASCII data from the NFS transfers?

Through aliasing the URB was given a page that contains said (previously)
received file. The ethernet chip/usb host does not write anything in it.
There could be a device or a driver problem but it may not be the real
problem.

So far the analysis focused on "how was this corrupted content written into
this receive buffer page ?". If I read David correctly (?) the "nobody
else has a pointer to it other than the USB host controller" point may be
replaced with "the pointer to it aliases some already used page".

-- 
Ueimor
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

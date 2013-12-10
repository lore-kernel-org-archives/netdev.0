From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/1] AX88179_178A: Enable the hardware pseudo header in
 case of the NET_IP_ALIGN equals 0
Date: Mon, 09 Dec 2013 20:01:31 -0500 (EST)
Message-ID: <20131209.200131.1376169274733452706.davem@davemloft.net>
References: <1386323898-2246-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, louis-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org
To: freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1386323898-2246-1-git-send-email-freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org
Date: Fri,  6 Dec 2013 17:58:18 +0800

> From: Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
> 
> The AX88179_178A has a hardware feature that it can insert a 2-bytes pseudo
> header in front of each received frame by setting the AX_RX_CTL_IPE bit.
> This feature is used to let the IP header be aligned on a doubleword-aligned address,
> but the NET_IP_ALIGN may equals to 2 and the __netdev_alloc_skb_ip_align in USBNET will
> reserve 2 bytes also, so in this case the driver shouldn't enable this bit.
> 
> This patch modifies the driver to set AX_RX_CTL_IPE just in case of the NET_IP_ALIGN equals 0.
> 
> Signed-off-by: Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>

Please avoid larger than 80 column lines in your commit messages,
people use text-only tools to viee these.

Next, it makes no sense to restrict your change to NET_IP_ALIGN==0

Simply handle any case, by undoing the reservation if it's getting
in the way.  If there isn't an appropriate helper for this, add one.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

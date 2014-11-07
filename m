From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] r8152: adjust rtl_start_rx
Date: Fri, 07 Nov 2014 11:35:22 -0500 (EST)
Message-ID: <20141107.113522.837502028522211960.davem@davemloft.net>
References: <1394712342-15778-88-Taiwan-albertk@realtek.com>
	<1394712342-15778-90-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-90-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Date: Fri, 7 Nov 2014 17:55:11 +0800

> Submit all the rx buffers, even though a error occurs. Otherwise
> the buffers which are not submitted would be lost until next
> rtl_start_rx() is called. Besides, the fail buffer could be
> re-submitted later.
> 
> Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>

Does this even work?

If you leave a hole in the ring, the device is going to stop there
anyways.

So better to replenish the next time you call into this function
rather than leaving gaps in your receive ring.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

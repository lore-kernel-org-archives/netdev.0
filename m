From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 1/3] net/usb/r815x: replace USB buffer from stack to
 DMA-able
Date: Sat, 27 Jul 2013 20:21:07 -0700 (PDT)
Message-ID: <20130727.202107.555068116238400560.davem@davemloft.net>
References: <20130724.174947.452272360732442554.davem@davemloft.net>
	<1374739144-732-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1374739144-732-1-git-send-email-hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 25 Jul 2013 15:59:02 +0800

> Some USB buffers use stack which may not be DMA-able.
> Use the buffers from kmalloc to replace those one.
> 
> Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>

I don't think it's reasonable to kmalloc() a small integer every time
you want to use a USB message transfer to read or write chip
registers.

Instead, add a scratch buffer to struct r8152 which is allocated once
at driver attach time and which you can use for the transfers.

I think you only need an array of two u32's so something like:

	u32		transfer_buf[2];

ought to be sufficient.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

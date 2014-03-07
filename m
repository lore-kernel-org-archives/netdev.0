From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] r8152: tx/rx improvement
Date: Fri, 07 Mar 2014 16:27:32 -0500 (EST)
Message-ID: <20140307.162732.1801095905509663010.davem@davemloft.net>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	<1394161480-2918-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394161480-2918-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 7 Mar 2014 11:04:33 +0800

>  - Select the suitable spin lock for each function.
>  - Add additional check to reduce the spin lock.
>  - Up the priority of the tx to avoid interrupted by rx.
>  - Support rx checksum, large send, and IPv6 hw checksum.

Series applied, thanks.

Note that if you ever add ->ndo_poll_controller support to this driver,
you will have to revert your spin_lock_irq{save,restore}() changes to
your ->ndo_start_xmit.

Because the transmit function can indeed be invoked from hard IRQ
context once you support netpoll.

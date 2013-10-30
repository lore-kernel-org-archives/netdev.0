From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/cdc_ncm: fix null pointer panic at
 usbnet_link_change
Date: Tue, 29 Oct 2013 22:38:23 -0400 (EDT)
Message-ID: <20131029.223823.1852248673779937090.davem@davemloft.net>
References: <0C18FE92A7765D4EB9EE5D38D86A563A019F450F@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: changbinx.du@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0C18FE92A7765D4EB9EE5D38D86A563A019F450F@SHSMSX103.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Du, ChangbinX" <changbinx.du@intel.com>
Date: Tue, 29 Oct 2013 03:30:42 +0000

> In cdc_ncm_bind() function, it call cdc_ncm_bind_common() to setup usb.
> But cdc_ncm_bind_common() may meet error and cause usbnet_disconnect()
> be called which calls free_netdev(net). Thus usbnet structure(alloced
> with net_device structure) will be freed,too.
> So we cannot call usbnet_link_change() if cdc_ncm_bind_common() return
> error.

This is not the bug.

The problem is in cdc_ncm_bind_common().

It seems to leave dangling interface data pointers in some cases, and
then branches just to "error" so that they don't get cleared back out.

This bypasses the protection present in cdc_ncm_disconnect() meant to
avoid this problem.

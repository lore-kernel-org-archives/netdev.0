From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net 2/2] r8152: reset device when tx timeout
Date: Tue, 28 Jul 2015 10:56:39 +0200
Message-ID: <1438073799.11934.4.camel@suse.com>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
	 <1394712342-15778-158-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-158-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-28 at 15:36 +0800, Hayes Wang wrote:
> The device reset is necessary if the hw becomes abnormal and stops
> transmitting packets.

You are not the first one to face this problem. Hence there
is a helper:

 * usb_queue_reset_device - Reset a USB device from an atomic context
 * @iface: USB interface belonging to the device to reset
 *
 * This function can be used to reset a USB device from an atomic
 * context, where usb_reset_device() won't work (as it blocks).

Please use it if you can. Your version for example is buggy.
It will oops if you unplug the device while a reset is scheduled.

	Regards
		Oliver

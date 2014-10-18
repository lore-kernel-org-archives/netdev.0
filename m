From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net] r8152: use cancel_delayed_work for runtime suspend
Date: Sat, 18 Oct 2014 21:48:19 +0200
Message-ID: <1413661699.19391.2.camel@linux-0dmf.site>
References: <1394712342-15778-64-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-64-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-10-17 at 13:55 +0800, Hayes Wang wrote:
> It would cause dead lock for runtime suspend, when the workqueue
> is running and runtime suspend occurs before the workqueue wakes
> up the device. The rtl8152_suspend() waits the workqueue to finish
> because of calling cancel_delayed_work_sync(). The workqueue waits
> the suspend function to finish for waking up the device because of
> calling usb_autopm_get_interface().

The diagnosis is good, the fix is not good. It opens a race
during which the queued work can touch a suspended device.

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

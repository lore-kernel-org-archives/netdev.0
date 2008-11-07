From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2] usbnet: enable more aggressive autosuspend
Date: Fri, 07 Nov 2008 03:26:33 -0500
Message-ID: <4913FBB9.70407@garzik.org>
References: <490080F1.1060107@t2data.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org
To: Per Hallsmark <per.hallsmark-8A+B91M1NdOzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <490080F1.1060107-8A+B91M1NdOzQB+pC5nmwQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Per Hallsmark wrote:
> Enable more aggressive autosuspend in usbnet.
> Some commenting and cleanups done.
> Signed-off-by: Per Hallsmark <per-46Ss7X5r2El6nIa31vAvqA@public.gmane.org>

Actually, this breaks the !CONFIG_PM build:

drivers/net/usb/usbnet.c: In function 'usbnet_suspend':
drivers/net/usb/usbnet.c:1357: error: 'struct usb_device' has no member 
named 'auto_pm'

I pondered taking the easy route of fixing this by surrounding the 
auto_pm reference with an ifdef, but it seems like usbnet could use a 
bit more thought -- it is questionable whether usbnet_suspend/resume 
should be built at all, if !CONFIG_PM, even though they are exported.

	Jeff



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

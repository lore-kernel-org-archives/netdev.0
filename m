From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V3] usbnet: fix race condition caused spinlock bad
 magic issue
Date: Thu, 14 Nov 2013 08:44:42 +0100
Message-ID: <1384415082.18291.8.camel@linux-fkkt.site>
References: <1384394595.4229.24.camel@wangbiao>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ingo Molnar <mingo.kernel.org-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org,
	rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, william.douglas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	di.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: wangbiao <biao.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384394595.4229.24.camel@wangbiao>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-11-14 at 10:03 +0800, wangbiao wrote:
> From: wang, biao <biao.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Date: Mon, 11 Nov 2013 10:23:40 +0800
> Subject: [PATCH] usbnet: fix race condition caused spinlock bad magic issue
> 
> there is race between usbnet_terminate_urbs and usbnet_bh.
> for example:
>     cpu 0                                     cpu 1
>                                           usbnet_suspend
> usbnet_bh {                               ->usbnet_terminate_urbs {
>                                               dev->wait = &unlink_wakeup;
>                                               while(....){..}//break
>     if(dev->wait) is true
>                        		              dev->wait=NULL
>                                           }//unlink_wakeup is invalid
>     __wake_up(dev->wait)//garbage value
> }
> 
> the race is due to unprotection of dev->wait, so this patch involves a
> spinlock to avoid it.
> 
> Signed-off-by: wang, biao <biao.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Zhang, Di <di.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Acked-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/8] mwifiex: only call mwifiex_sdio_probe_of() if dev has
 an OF node
Date: Wed, 1 Jun 2016 14:14:25 +1000
Message-ID: <CAGRGNgWHGR_KJW1SExte-YSG1ynxy-GrtKjO-GRKEadUx4HpWA@mail.gmail.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com> <1464358702-19083-2-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Xinming Hu <huxm-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: Javier Martinez Canillas <javier-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464358702-19083-2-git-send-email-javier-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

On Sat, May 28, 2016 at 12:18 AM, Javier Martinez Canillas
<javier-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org> wrote:
> SDIO is an auto enumerable bus so the SDIO devices are matched using the
> sdio_device_id table and not using compatible strings from a OF id table.
>
> However, commit ce4f6f0c353b ("mwifiex: add platform specific wakeup
> interrupt support") allowed to match nodes defined as child of the SDIO
> host controller in the probe function using a compatible string to setup
> platform specific parameters in the DT.
>
> The problem is that the OF parse function is always called regardless if
> the SDIO dev has an OF node associated or not, and prints an error if it
> is not found. So, on a platform that doesn't have a node for a SDIO dev,
> the following misleading error message will be printed:
>
> [  12.480042] mwifiex_sdio mmc2:0001:1: sdio platform data not available
>
> Signed-off-by: Javier Martinez Canillas <javier-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>

This looks sensible to me.

Reviewed-by: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

>  drivers/net/wireless/marvell/mwifiex/sdio.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Thanks,

-- 
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

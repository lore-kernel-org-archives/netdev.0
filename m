From: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH v4 1/2] HID: Add Support for Setting and Getting Feature
 Reports from hidraw
Date: Fri, 1 Oct 2010 15:30:21 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1010011529460.29535@pobox.suse.cz>
References: <1281442367.12579.206.camel@localhost.localdomain> <1281990059-3562-2-git-send-email-alan@signal11.us> <20100928153011.32750e5d.ospite@studenti.unina.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>,
	Stefan Achatz <erazor_de-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Stephane Chatty <chatty-rXV5z7KbLFk@public.gmane.org>,
	Michael Poole <mdpoole-IZmAEv5cUt1AfugRpC6u6w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Bastien Nocera <hadess-0MeiytkfxGOsTnJN9+BGXg@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Antonio Ospite <ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100928153011.32750e5d.ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2010, Antonio Ospite wrote:

> Hi Alan, I am doing some stress testing on hidraw, if I have a loop with
> HIDIOCGFEATURE on a given report and I disconnect the device while the
> loop is running I get this:
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000028
> IP: [<ffffffffa02c66b4>] hidraw_ioctl+0xfc/0x32c [hid]
> 
> Full log attached along with the test program, the device is a Sony PS3
> Controller (sixaxis).
> 
> If my objdump analysis is right, hidraw_ioctl+0xfc should be around line
> 361 in hidraw.c (with your patch applied):
> 
> struct hid_device *hid = dev->hid;
> 
> It looks like 'dev' (which is hidraw_table[minor]) can be NULL
> sometimes, can't it?
> This is not introduced by your changes tho.
> 
> Just as a side note, the bug does not show up if the userspace program
> handles return values properly and exits as soon as it gets an error
> from the HID layer, see the XXX comment in test_hidraw_feature.c.
> 
> This fixes it, if it looks ok I will resend the patch rebased on
> mainline code:
> 
> diff --git a/drivers/hid/hidraw.c b/drivers/hid/hidraw.c
> index 7df1310..3c040c6 100644
> --- a/drivers/hid/hidraw.c
> +++ b/drivers/hid/hidraw.c
> @@ -322,6 +322,10 @@ static long hidraw_ioctl(struct file *file, unsigned int cmd,
> 
>         mutex_lock(&minors_lock);
>         dev = hidraw_table[minor];
> +       if (!dev) {
> +               ret = -ENODEV;
> +               goto out;
> +       }
> 
>         switch (cmd) {
>                 case HIDIOCGRDESCSIZE:
> @@ -412,6 +416,7 @@ static long hidraw_ioctl(struct file *file, unsigned int cmd,
> 
>                 ret = -ENOTTY;
>         }
> +out:
>         mutex_unlock(&minors_lock);
>         return ret;
>  }

Yes, this patch makes sense even for current mainline code. Could you 
please resend it to me with Signed-off-by: and changelog text, so that I 
could apply it?

Thanks!

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

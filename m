From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Fri, 17 Apr 2009 19:55:29 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904171952260.4042@localhost.localdomain>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera> <d82e647a0904161837w6b6fb652la0da05f9061e95dc@mail.gmail.com> <200904172336.12414.rjw@sisk.pl> <20090418103226.54250420@linux-lm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	video4linux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, laurent.pinchart-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: leiming <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090418103226.54250420@linux-lm>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Sat, 18 Apr 2009, leiming wrote:
> 
> >From 5715e310a939f3f7cd3e88eae8f25fedbb28def4 Mon Sep 17 00:00:00 2001
> From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Wed, 15 Apr 2009 22:32:51 +0800
> Subject: [PATCH] V4L/DVB:usbvideo:fix uvc resume failed
> 
> Now urb buffers is not freed before suspend, so uvc_alloc_urb_buffers
> should return packet counts allocated originally during uvc resume
> , instead of zero.
> 
> This patch is against v2.6.30-rc2.
> 
> Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/media/video/uvc/uvc_video.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/media/video/uvc/uvc_video.c b/drivers/media/video/uvc/uvc_video.c
> index a95e173..c050b22 100644
> --- a/drivers/media/video/uvc/uvc_video.c
> +++ b/drivers/media/video/uvc/uvc_video.c
> @@ -742,7 +742,7 @@ static int uvc_alloc_urb_buffers(struct uvc_video_device *video,
>  
>  	/* Buffers are already allocated, bail out. */
>  	if (video->urb_size)
> -		return 0;
> +		return DIV_ROUND_UP(video->urb_size, psize);

I don't think this is right. It should round _down_.

It's supposed to return 'npackets', but if you pass it a different packet 
size than it was passed originally, it can now return a potentially bigger 
number than the already allocated buffer, no?

So I think it should round down (ie use a regular divide). No?

		Linuse

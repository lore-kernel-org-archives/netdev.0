From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: [PATCH 0/10] use safer test on the result of find_first_zero_bit
Date: Wed, 4 Jun 2014 13:07:34 +0200
Message-ID: <CAMuHMdV2wP43Lxf-UtCum37HyMPSboRb6RLNTHzm_ZNOBeJR0g@mail.gmail.com>
References: <1401872880-23685-1-git-send-email-Julia.Lawall@lip6.fr>
	<CAMuHMdXsoFUXj4jLMWN6NY7Um19KwWO9Rhx=9=gqWu_K5Ev2kQ@mail.gmail.com>
	<alpine.DEB.2.10.1406041137270.2441@hadrien>
	<063D6719AE5E284EB5DD2968C1650D6D1725705F@AcuExch.aculab.com>
	<alpine.DEB.2.10.1406041148590.2441@hadrien>
	<CAMuHMdXPBQTYA0c=1hkC7943-_J59TVSFaEKsfY1F2ogV=Ld+A@mail.gmail.com>
	<alpine.DEB.2.10.1406041258200.2441@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Fbdev development list <linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-sh list <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	driverdevel <devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>,
	"iss_storagedev-VXdhtT5mjnY@public.gmane.org" <iss_storagedev-VXdhtT5mjnY@public.gmane.org>,
	scsi <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-s390 <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
To: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.10.1406041258200.2441@hadrien>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Julia,

On Wed, Jun 4, 2014 at 1:00 PM, Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org> wrote:
> OK, thanks.  I was only looking at the C code.
>
> But the C code contains a loop that is followed by:
>
>         if (!size)
>                 return result;
>         tmp = *p;
>
> found_first:
>         tmp |= ~0UL << size;
>         if (tmp == ~0UL)        /* Are any bits zero? */
>                 return result + size;   /* Nope. */
>
> In the first return, it would seem that result == size.  Could the second
> one be changed to just return size?  It should not hurt performance.

"size" may have been changed between function entry and this line.
So you have to store it in a temporary.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

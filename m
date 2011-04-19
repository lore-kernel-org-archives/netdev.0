From: Paul Stewart <pstew@chromium.org>
Subject: Re: [PATCH] usbnet: Resubmit interrupt URB more often
Date: Tue, 19 Apr 2011 10:51:54 -0700
Message-ID: <BANLkTinPpmOUABRg0Fx84VGiZhKdw=Ok0Q@mail.gmail.com>
References: <20110419164703.5A6A82052B@glenhelen.mtv.corp.google.com>
	<1303233066.2988.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:36428 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680Ab1DSRv5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 13:51:57 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p3JHpu9h000481
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 10:51:56 -0700
Received: from iwn9 (iwn9.prod.google.com [10.241.68.73])
	by wpaz33.hot.corp.google.com with ESMTP id p3JHokwJ015941
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 10:51:54 -0700
Received: by iwn9 with SMTP id 9so16148107iwn.37
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 10:51:54 -0700 (PDT)
In-Reply-To: <1303233066.2988.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Ben. =A0I've made some changes.  usbnet.c is a little bit a of
mess style-wise, and I let myself get sucked in. :-)

--
Paul

On Tue, Apr 19, 2011 at 10:11 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> On Tue, 2011-04-19 at 09:35 -0700, Paul Stewart wrote:
> [...]
> > index 4342bd9..e4dbb29 100644
> > --- a/drivers/usb/core/urb.c
> > +++ b/drivers/usb/core/urb.c
> > @@ -295,7 +295,9 @@ int usb_submit_urb(struct urb *urb, gfp_t mem_f=
lags)
> > =A0 =A0 =A0 struct usb_host_endpoint =A0 =A0 =A0 =A0*ep;
> > =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 is_out;
> >
> > - =A0 =A0 if (!urb || urb->hcpriv || !urb->complete)
> > + =A0 =A0 if (urb->hcpriv)
> > + =A0 =A0 =A0 =A0 =A0 =A0 return -EALREADY;
> > + =A0 =A0 if (!urb || !urb->complete)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> [...]
>
> The test for !urb must come before the test on urb->hcpriv.
>
> Also, the kernel coding style does not allow '//' comments. =A0Please=
 use
> scripts/checkpatch.pl to check for style and other common errors.
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>

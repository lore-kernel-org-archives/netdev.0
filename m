From: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Wed, 20 Apr 2011 14:17:10 -0700
Message-ID: <BANLkTi=N3T-V8VNOcbKu6COKvbEHqMoAog@mail.gmail.com>
References: <20110420195015.20A96201B8@glenhelen.mtv.corp.google.com>
	<Pine.LNX.4.44L0.1104201658280.1686-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1104201658280.1686-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 20, 2011 at 2:08 PM, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>=
 wrote:
> On Tue, 19 Apr 2011, Paul Stewart wrote:
>
>> Set a flag if the interrupt URB completes with ENOENT as this
>> occurs legitimately during system suspend. =A0When the usbnet_bh
>> is called after resume, test this flag and try once to resubmit
>> the interrupt URB.
>
> No doubt there's a good reason for doing things this way, but it isn'=
t
> clear. =A0Why wait until usbnet_bh() is called after resume? =A0Why n=
ot
> resubmit the interrupt URB _during_ usbnet_resume()?

Actually, I was doing this in the bh because of feedback I had gained
early in this process about not doing submit_urb in the resume().  If
that issue doesn't exist, that makes my work a lot easier.  In testing
I found that just setting this to happen in the bh might be problematic
due to firing too early, so this is good news.

>=A0This would seem
> to be the logical approach, seeing as how usbnet_suspend() kills the
> interrupt URB.

Aha!  But you'll see from the current version of my patch that we don't
actually ever kill the interrupt URB.  It gets killed all on its own (b=
y the
hcd?) and handed back to us in intr_complete().  This last bit about th=
e
complete function being called was lost on me for a while which is why
in a previous iteration of the patch I was trying to kill the urb in su=
spend().

> For that matter, where does the interrupt URB get deallocated? =A0It
> obviously gets allocated in init_status(), but it doesn't seem to be
> freed anywhere.

That's a very interesting question and one that I noticed as well.
I was going to tackle that as a separate issue.

>
> Alan Stern
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

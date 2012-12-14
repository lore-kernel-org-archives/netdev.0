From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCHv2][RFC] smsc95xx: enable dynamic autosuspend
Date: Fri, 14 Dec 2012 15:22:31 +0100
Message-ID: <4228102.c0z2lbILKD@linux-lqwf.site>
References: <1355239561-2740-1-git-send-email-steve.glendinning@shawell.net> <CACVXFVNf1EWfnQmDBDoF991cqJOb8g_Ws+tuyBJdE34rbO6GSw@mail.gmail.com> <CAKh2mn7C3r_bvKAv4p3AHco=9JpmewOAJ8JwhtFPw50yDy5cUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKh2mn7C3r_bvKAv4p3AHco=9JpmewOAJ8JwhtFPw50yDy5cUA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 14 December 2012 13:35:04 Steve Glendinning wrote:

> Thanks Ming, I've updated this.

Very good. Good catch Ming.

> > IMO, it is better to keep smsc95xx_info.manage_power as NULL
> > for devices without FEATURE_AUTOSUSPEND, so that fewer code
> > and follow the current .mange_power usage(see its comment).
> >
> > Currently, if the function pointer of manage_power is set, it means that
> > the device supports USB autosuspend, but your trick will make the

manage_power() can return errors. So the assumption was always
strictly speaking invalid.

> > assumption not true for some smsc devices.
> 
> Oliver?

On second thought, I think that if a driver can do manage_power(), even
only for a subset of devices, it should implement it. Doctoring the table of methods
is very, very ugly, especially as this not protected by a lock.

But this is not nice. We need a better way.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

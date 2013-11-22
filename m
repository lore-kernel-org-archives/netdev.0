From: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] Workaround for Suspend/Resume issue of AX88772B under ChromeOS
Date: Thu, 21 Nov 2013 18:26:22 -0800
Message-ID: <CANEJEGuo4rbz4hP=RfN8A+4ozjuJ7oZmtLcmkjbkxrGZrpRr5A@mail.gmail.com>
References: <1384913496-26261-1-git-send-email-freddy@asix.com.tw>
	<20131120.004026.2013972041095203460.davem@davemloft.net>
	<CANEJEGtBmvFNcFzOW9ZnOFd=ZMnz82ajcN52YqW3+n0+=rhxBA@mail.gmail.com>
	<20131120.135413.920731121262719289.davem@davemloft.net>
	<CANEJEGtXOjxj+85QVfWFGH6WuxxCz6uAfEuUo7bv9YEwh_8OAw@mail.gmail.com>
	<CANEJEGu_2YdVOjcnzh30RPMiP0KC5bL6JasxMS_+1xV9poxgQw@mail.gmail.com>
	<CAGVrzcase25NosVHA74OLnviJj7nU_2Rxki_hvi8bOwznDuWGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, davemloft-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	=?UTF-8?B?QVNJWCBMb3VpcyBb6JiH5aiB6Zm4XQ==?= <louis-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Daniel_ASIX <daniel-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGVrzcase25NosVHA74OLnviJj7nU_2Rxki_hvi8bOwznDuWGg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 21, 2013 at 5:58 PM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
...
>> Freddy sent me a patch that saves/restores MII_ADVERTISE and MII_BMCR
>> registers. Testing that now and he'll post if that all works out.

Bad News: Freddy's patch didn't work and needs to be rework it.

> That should be enough to ensure the PHY is put back into a consistent
> state. So long as you are suspending/resuming from a configuration
> where autoneg was enabled, I would not expect anything bad to happen.

Well, I think davem NACK'd that approach (the original patch in this
thread did that).

> If the link was forced, that is a different story.
>
> One way to make sure this work properly without driver-specific code
> is to include that functionality into the PHY library. As far as I can
> see it the asix drivers do not use it but implement the old-style
> mii_bus interface so that would be a first step.

AFAICT, many USBNET drivers support mii_bus interface. Can you point
at a good example of a USBNET driver that is supporting PHY lib?

I also didn't see anything in usbnet_resume() code path that calls
into a phy lib. So it seems that some infrastructure still needs to
happen if that's considered a feasible.

thanks,
grant

> --
> Florian
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Jaroslaw Fedewicz <jafd-cTM//Nd5/DKCo84Yma55WQ@public.gmane.org>
Subject: Re: [Bug?] Machine hangs, rtl8192se possible cause
Date: Tue, 2 Aug 2011 02:10:49 +0300
Message-ID: <CAFdoEiRBPMx0C+YXwd4-Q=_nHpOb+r2+GspwujZrPh6S4tDwEQ@mail.gmail.com>
References: <CAFdoEiT54o+NQKO=dAcOXgyf6GJ1E51w_H_p7PJyRmynz8Sbzg@mail.gmail.com>
	<4E36C693.6000705@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E36C693.6000705-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> What kernel are you using? The only problems I've had were some kernel
> panics due to improper handling of memory allocation failures with the
> receive skb's, but they have been fixed.
>

I'm using a fairly recent version of kernel from git (I think from
before yesterday). The mysterious hangs were there from the beginning,
but it also might be partly because ATI driver was messed up too at
these times. Later, ati appeared fixed but the hangs wouldn't go away.

I don't think it's a panic proper, though. Nothing ever gets logged
along the lines of "panic". Even if I happen to have a text mode
console, it just freezes. If I have a panic or an oops proper, I'm
also kicked out of X11 to see it by the KMS. But not in this case.

(Also, the laptop has neither Caps Lock nor Num Lock nor Scroll Lock
LEDs, so I can't see if they blink.)

What raised my suspicions is that I've never seen this happen when
rtl8192se wasn't compiled at all or was not loaded.

> It can be difficult to use netconsole to debug problems with wireless
> devices.

I can hook netconsole to the Ethernet and it *might* manage to log the
last packet (at least I used to reason that way when screen just
froze). The trick is, it never did log anything spurious. Just your
normal initialization messages and then it just stops.

>
> As you prevent rtl8192se from loading automatically, the logging console may
> provide some clues. Use the following command to load the driver:
>
> sleep 10 ; modprobe rtl8192se
>
> During the 10 second sleep, use CTRL-ALT-F10 to switch consoles and see if
> any messages appear.
>

The most problematic thing is that it does not hang right away. Most
of the time, I see the machine go into the catatonia after quite a
while, and as it is not the laptop I do most of my work on, I usually
see it hanged when screen PM has already kicked in. So I cannot really
read what the log might say on the matter.

I cannot also trigger the freeze reliably. Most of the time it happens
"when you are not looking at it", and it usually happens either during
or just after high load averages and low to none network activity (a
typical scenario: build a firefox from sources, go outside, come home
4 hours later, the laptop is turned on but dead by hanging; no
messages as the screen is obviously off; a less typical scenario is to
freeze during startup).

I'm the last person ever to suggest anything on the subject, but could
it be a problem in the card's power management?

> Please use 'lspci -nn' to determine which version of the card you have.

03:00.0 Network controller [0280]: Realtek Semiconductor Co., Ltd.
RTL8191SEvB Wireless LAN Controller [10ec:8172] (rev 10)

If there is a test I can conduct or any other information to provide,
please let me know.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

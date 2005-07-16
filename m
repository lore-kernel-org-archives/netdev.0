From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] forcedeth: TX handler changes (experimental)
Date: Sat, 16 Jul 2005 22:24:57 +0100
Message-ID: <42D97B29.4050400__14781.7154917449$1121549423$gmane$org@gentoo.org>
References: <42D913D6.5050902@colorfullife.com> <42D9658B.7020907@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <42D9658B.7020907@gentoo.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> After applying the v0.38 patch, I can't get any network at all. DHCP 
> fails to get an IP. v0.37 works fine.

Tracked it down. (sorry for linewraps)

+#define DEV_NEED_TIMERIRQ	0x0001  /* set the timer irq flag in the irq mask */
+#define DEV_NEED_LINKTIMER	0x0002	/* poll link settings. Relies on the timer 
irq */
+#define DEV_HAS_LARGEDESC	0x0003	/* device supports jumbo frames and needs 
packet format 2 */

My hardware is NEED_TIMERIRQ|NEED_LINKTIMER, however, by this logic, it'll 
also be DEV_HAVE_LARGEDESC, which isn't true.

So, you want this instead:

#define DEV_HAS_LARGEDESC	0x0004

After making that change, all is working fine, but then again, I've never run 
into the hangs you are debugging. I'll follow up in a couple of days time to 
confirm I'm not getting any problems with the new code.

Thanks,
Daniel

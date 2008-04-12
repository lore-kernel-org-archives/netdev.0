From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8111c weirdness problems, apic/msi, and normal bug
Date: Sat, 12 Apr 2008 21:22:15 +0200
Message-ID: <20080412192215.GA17669@electric-eye.fr.zoreil.com>
References: <1207407804.14885.27.camel@localhost> <20080405232354.57ff2fac.akpm@linux-foundation.org> <20080406140624.GA24479@electric-eye.fr.zoreil.com> <1207541340.30698.18.camel@localhost> <1207829872.1514.3.camel@localhost> <1207876315.1514.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML Mailinglist <linux-kernel@vger.kernel.org>,
	linux-acpi@vger.kernel.org, netdev@vger.kernel.org
To: Kasper Sandberg <lkml@metanurb.dk>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1207876315.1514.21.camel@localhost>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kasper Sandberg <lkml@metanurb.dk> :
> Sorry for top posting, but its just easier in this case :)

Tsk, tsk.

> I may have just gotten some new information to share.
> 
> I just built -git8. and the nic didnt work.. by booting with
> noapic/nomsi i got it running though. then i did some tests, and
> rebooted into the default(has worked mostly for me) noapic/msi boot.
> Then it worked.

Can you try a simple 'nomsi' boot ?

The lspci in your previous message (2008/04/10) suggested that
something was very wrong at the PCI level:
[...]
05:00.0 0200: 10ec:8168 (rev ff) (prog-if ff)
        !!! Unknown header type 7f
        Kernel driver in use: r8169
        Kernel modules: r8169
00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
10: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
20: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
30: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

(but this was on an older kernel, right ?)

When you see such an output, can you try to see if the direct access
option of lspci (-H{1/2}) makes a difference ?

[...]
> if its a boot where the nic works, i can usually rmmod/modprobe the
> module once without it giving error, however if its a boot where the nic
> doesent work, first time i rmmod and modprobe, it gives me an error..
> 
> the error is:
> PCI: cache line size of 32 is not supported by device 0000:05:00.0
> ACPI: PCI interrupt for device 0000:05:00.0 disabled
> r8169: probe of 0000:05:00.0 failed with error -22

What does lspci say here ?

> I have attached some dmesgs(sorry, but my client messes up inlines..)
> also.. link detecting isnt working properly, sometimes it will detect a
> link as down after a while.. its quite weird..

(please increase the size of your kernel log buffer)

> (oh, and this time its without nvidia just to be 100000% sure)

Thanks.

> I hope this can help to get it resolved, alot of people are having
> problems with these controllers.. i can however confirm that a similar
> controller is working perfectly on a friends gigabyte motherboard, thats
> with P35 chipset though, i have X48. He has only 1 of them onboard.

You can ask your friend to grep for the 'XID' line in the kernel log
written by the r8169 driver. If the values match, you have got the same
816x hardware.

There are different problems with the 8168
- older kernel with broken mmconfig / msi / etc.
- newer 8168 chipsets which are currently not correctly handled
- plain 8168 driver bugs
- ...

(that being said, it really works for some users too)

> also something which may be of interrest, realtek offers a modified
> r8169 driver called "r8168", which supposedly fixes this. I have been
> unable to get it to compile though, but i saw it on ubuntu forums.

I am looking very closely at Realtek's drivers but the diff between 
the different revisions of their 8168 driver are not always as
readable as I would hope for (things have improved though).

Realtek is working at fixing its 8168 driver for recent kernels. It
should be easier to compare its behavior against the in-kernel driver
with recent kernels soon. It will makes everybody's life easier.

-- 
Ueimor

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: crappy/good gigabit chipsets?
Date: Sat, 27 Nov 2004 14:47:06 +0100
Message-ID: <20041127134706.GA28907@electric-eye.fr.zoreil.com>
References: <41A81C15.5080905@gmx.net> <20041127111009.GB23139@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20041127111009.GB23139@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek <buytenh@wantstofly.org> :
[...]
> I'm not much of an expert, but I do have some experience to share.

AOL

> I tried r8169 (Realtek gigabit chipset, used in various el-cheapo
> GigE cards) in a cheap Asus mainboard in a 32/33 slot, and when
> driver spewing out various scary-looking PCI errors to the console.
> throwing enough packets at it the card would just stall with the

<r8169 maintainer hat on>

- which chipset on the motherboard ?
- do you have some (even gross) figures for the required packet rate ?
- is your computer with the r8169 adapter still available for testing ?

People, please report such behavior. Even if you do not have time to
further help fixing it, it really helps me to know own many hit the
issue. Bugzilla or mail are fine with me.

> Didn't have time to look into it further at the time (this was on
> 2.6.9-something.)  Might not be the NIC's fault.

Sensible. Without further documentation related to the recovery for
this specific issue (DAC related PCI errors are a different beast),
I assumed that the safer thing was to disable the device.

At least on x86, under load, I would not be surprised if it makes 
zero difference to ignore the PCI error. Before this check was introduced,
there was no identified complaint related to the stability of the driver
in the vanilla kernel.

More specifically, Google shows many people with r8169 issues. At the end
of the day, there are mostly related to old drivers, flaky hardware,
gcc 2.95.x, lovecraftian build of the kernel and such. Pending issues:
1) a complete failure on an amd64 laptop I'll be happy to see disappear in
   the "acpi killed me" category. Hopefully the things seem to improve
   on the acpi side.
2) Ben Greear experiences some troubles with a pcmcia adapter on its laptop.
   I have recently got the hardware to dig this issue.
3) gcc 2.95.4 related failure.
4) misc pci error reports on x86 since the code for it has been added.
   The pattern is not clear (chipset of the mobo ? cooling ? wtf ?).
5) DAC sucks on x86_64.

So far there are no known figures for the r8169 in the kind of setup that
Carl-Daniel plans to use.

> On an intel board with independent PCI buses, I see an e1000 'desktop'
> NIC filling the pipe for any packet size > ~350 when the card sits on
> its own PCI bus.  This is while running at 32/66, CPU being a 2.4GHz
> Xeon.

How do you fill it ?

--
Ueimor

From: Arjen Verweij <A.Verweij2@ewi.tudelft.nl>
Subject: Re: [Forcedeth] Wake-on-LAN support?
Date: Sat, 28 Feb 2004 01:40:16 +0100 (MET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GHP.4.44.0402280130470.13221-100000@elektron.its.tudelft.nl>
References: <400CACEB.6050307@gmx.net>
Reply-To: a.verweij@student.tudelft.nl
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
In-Reply-To: <400CACEB.6050307@gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Version 0.23 of forcedeth probably adds nice irq quirk checking for when
the kernel is running, but when I do evil stuff, like putting the NIC to
sleep (hard setting it to D3 with pci-config), the kernel keeps printing
one or more of the debug messages (when halting) about irqs that were
added and will no longer shut down.

My current fix is replacing the v0.23 from 2.6.3 with the v0.18. v0.18
also complains about the receiver remaining busy, but at least the
shutdown process is continued.

What I still don't understand is why I need a device driver at all to set
the power state of the NIC. If I unload forcedeth before shutting down, I
can set D3 all I want, but the machine will not listen to magic packets.

I'll add a section to my page about nforce2-c1-disconnect related lockups
about how to get functional WOL, and post the link here when it's ready. I
feel that this is useful information, because I cannot get a cheap card
with a WOL cable for my mobo, since there is no WOL connector *sigh*

Regards,

Arjen


On Tue, 20 Jan 2004, Carl-Daniel Hailfinger wrote:

> Arjen Verweij wrote:
> > L.S.,
> >
> > First, many thanks for your efforts. The driver works beautifully here,
> > with 2.4.23 and 2.6.0-test11 alike.
> >
> > I was wondering if it is possible to add Wake-on-LAN support to the
> > driver. NVidia claims their binary driver supports WOL, but it doesn't
> > work one bit. It is possible to look into this?
> >
> > I have filed a bugtracker with the ACPI people, but they are somewhat
> > understandably preoccupied with fixing laptop woes.
> >
> > URL:
> > http://bugzilla.kernel.org/show_bug.cgi?id=1636
> >
> > I am able to enable WOL at shutdown with pci-config from scyld.com, but
> > this is obviously an ugly fix.
>
> Hmmm... normally I would say enabling WOL is the job of the BIOS.
>
> Comments anyone?
>
> Setting Wake-on-LAN patterns will be supported in a future version of
> forcedeth but right now I'm swamped with university work.
>
>
> Carl-Daniel
> --
> http://www.hailfinger.org/
>
>
>

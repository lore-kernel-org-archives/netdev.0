From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: skge from 2.6.11-rc3-mm1 no workee either
Date: Mon, 7 Feb 2005 10:24:28 -0800
Message-ID: <20050207102428.5df9e529@dxpl.pdx.osdl.net>
References: <42064462.8060306@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: maxer <maxer@xmission.com>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <42064462.8060306@xmission.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 06 Feb 2005 09:22:58 -0700
maxer <maxer@xmission.com> wrote:

> This nic is on the mobo. sk98lin from kernel 2.6.9 works great. However:
> 
> If I go into Fedora Core's Network Device Control applet, it shows eth0 
> inactive. If I try to activate it I get:
> skge device eth0:1 does not seem to be present, delaying initialization.

The applet is good, but when there are problems will need to diagnose
with more direct commands.

> Jeff Garzik suggested that I send this to you.
> 
> Under Network Configuration tool trying to probe under "Bind to MAC 
> address gives the result as [Errno 19] No such device.
> 
> So while the driver clearly loads, it can't find the device nor activate 
> it.

The questions are:
	* does 'skge' get loaded?
		# lsmod
	* what is system log show related to skge
		# dmesg | grep skge


> What should I do to remedy this. I can bring up the device under kernel 
> 2.6.9, but no kernel beyond this 2.6.10 or 2.6.11-xx works.

Does it work with 'sk98lin' driver?
	# rmmod skge
	# modprobe sk98lin


> 04:00.0 Ethernet controller: Marvell Technology Group Ltd. Gigabit 
> Ethernet Controller (rev 17)
>        Subsystem: Intel Corp.: Unknown device 3065
>        Flags: bus master, fast devsel, latency 0, IRQ 3
>        Memory at ff720000 (64-bit, non-prefetchable) [size=16K]
>        I/O ports at a800 [size=256]
>        Expansion ROM at ff700000 [disabled] [size=128K]
>        Capabilities: [48] Power Management version 2
>        Capabilities: [50] Vital Product Data
>        Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/1 
> Enable-
>        Capabilities: [e0] Express Legacy Endpoint IRQ 0
>        Capabilities: [100] Advanced Error Reporting

Most likely this is a Marvell Yukon 2 chipset, which requires different
driver support. I infer this because it is the PCI-express version.
The only driver that handles Yukon2 on Linux is the version from Syskonnect's
web site, but don't think it still works with 2.6.10


-- 
Stephen Hemminger	<shemminger@osdl.org>

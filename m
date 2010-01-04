From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/defxx.c: use %pM to show MAC address
Date: Mon, 04 Jan 2010 11:03:26 -0800 (PST)
Message-ID: <20100104.110326.161162074.davem@davemloft.net>
References: <BD79186B4FD85F4B8E60E381CAEE19090200F63E@mi8nycmail19.Mi8.com>
	<alpine.LFD.2.00.1001041833560.13474@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hartleys@visionengravers.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753883Ab0ADTD3@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1001041833560.13474@eddie.linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Mon, 4 Jan 2010 18:49:48 +0000 (GMT)

>  Nack.  While I appreciate your effort, the FDDI standard defines opposite 
> bit-ordering for MAC addresses written in the dash-separated and the 
> colon-separated hexadecimal notation, which makes your change invalid, 
> sorry (you'd have to bit-swap them too and that would make addresses 
> counter-intuitive).  Please note that `ifconfig' consistently uses the 
> dash-separated notation for FDDI interfaces too (I haven't checked other 
> tools like those in the "iproute" package; they may be buggy).

Well:

1) It's a bootup kernel message, we can use whatever format
   we want.

2) As for consistency's sake, the only other FDDI driver using
   alloc_fddidev() and friends, skfp, uses yet another format
   for printing FDDI addresses to the log:

	pr_debug(KERN_INFO "HW-Addr: %02x %02x %02x %02x %02x %02x\n",

   So striving for "consistency" is a bit of a stretch.

   Against a userspace tool's output format?  Even more so...

And I doubt anybody is going to suddenly faint and become
confused if they see the MAC address in ethernet format.

In fact I'd rather see all of our FDDI drivers use the standard
ethernet MAC format in visible kernel log messages and save all
of that object code space that gets taken up by these by-hand
printk's in these obscure drivers.

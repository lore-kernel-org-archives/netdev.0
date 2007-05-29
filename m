From: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Tue, 29 May 2007 18:39:31 -0400
Message-ID: <465CABA3.10003@pobox.com>
References: <20070525172431.60affaca@freepuppy> <200705281655.15105.mb@bu3sch.de> <1180448075.17146.12.camel@dhcp-10-12-136-115.broadcom.com> <200705292245.22940.mb@bu3sch.de> <1180472741.17711.19.camel@dhcp-10-12-136-115.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1180472741.17711.19.camel-opBMJL+S1+nCw/J+WP9nZ0NK2P1VvzQgpWgKQ6/u3Fg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Gary Zambrano wrote:
> The b44 interrupt status reg returns a value of 0 if no interrupts are
> pending. The b44 uses a mask to determine which bits (events) can
> generate device interrupts on the system. If the masked interrupt status
> register bits are not asserted, then the b44 will return to the system
> with handled = 0. 
> So, I think the way the b44 interrupt code is written should be ok and
> not a bug. 


This is normal.

We check for 0xffffffff because that is often how a fault is indicated, 
when the memory location is read during or immediately after hotplug (or 
if the PCI bus is truly faulty).  So for most hardware, you see

tmp = read(irq status)
if (!tmp)
	return irq-none		/* no irq events raised */
if (tmp == 0xffffffff)
	return irq-none		/* hot unplug or h/w fault */

and the method that determines no interrupt handling is needed.

Regards,

	Jeff

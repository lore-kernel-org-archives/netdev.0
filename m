From: "Gary Zambrano" <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Tue, 29 May 2007 14:36:51 -0700
Message-ID: <1180474611.17711.26.camel@dhcp-10-12-136-115.broadcom.com>
References: <20070525172431.60affaca@freepuppy>
 <200705281655.15105.mb@bu3sch.de>
 <1180448075.17146.12.camel@dhcp-10-12-136-115.broadcom.com>
 <200705292245.22940.mb@bu3sch.de>
 <1180472741.17711.19.camel@dhcp-10-12-136-115.broadcom.com>
 <465CABA3.10003@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"Maximilian Engelhardt" <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	"linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Stephen Hemminger" <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Arnaldo Carvalho de Melo" <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "Jeff Garzik" <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <465CABA3.10003-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-29 at 18:39 -0400, Jeff Garzik wrote:

> We check for 0xffffffff because that is often how a fault is indicated, 
> when the memory location is read during or immediately after hotplug (or 
> if the PCI bus is truly faulty).  So for most hardware, you see
> 
> tmp = read(irq status)
> if (!tmp)
> 	return irq-none		/* no irq events raised */
> if (tmp == 0xffffffff)
> 	return irq-none		/* hot unplug or h/w fault */
> 
> and the method that determines no interrupt handling is needed.
> 

I guess you are right, but then shouldn't the driver be checking for
faults in other parts of the code too? What if a fault/hotplug occurs
immediately after an interrupt, but before a tx?
Thanks,
Gary

From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [RFR] new e100 driver
Date: Fri, 5 Dec 2003 16:43:47 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031205164347.B1291@sygehus.dk>
References: <20031205063842.GA23843@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20031205063842.GA23843@gtf.org>; from jgarzik@pobox.com on Fri, Dec 05, 2003 at 01:38:43AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Dec 05, 2003 at 01:38:43AM -0500, Jeff Garzik wrote:
> 
> e100 3.0.9_dev just got checked into net-drivers-2.5-exp queue.  As I do
> occasionally (especially for smaller drivers), I post them for review
> and comment.

How would I build it? A patch for the Makefile is missing.

> Patches welcome in addition to comments.
> 
> One thing I am tempted to request is use of the new module_param()...

Does anybody have a macro that turns module_parm() into MODULE_PARM() for
2.4 compatibility?

>  *	References:
>  *		Intel 8255x 10/100 Mbps Ethernet Controller Family,
>  *		Open Source Software Developers Manual,
>  *		http://sourceforge.net/projects/e1000
[cut]
>  * 	Hardware padding of short packets to minimum packet size is
>  * 	enabled.  82557 pads with 7Eh, while the later controllers pad
>  * 	with 00h.

I would be nice if the documentation said so. A few days ago I spent half an
hour or so trying to figure out why frames sent by an 82558 were padded with
0x00 rather than the documented 0x7e (with no sign of skb_padto(), memset()
or anything similiar in the driver).

> enum mac {
> 	mac_82557_D100_A  = 0,
> 	mac_82557_D100_B  = 1,
> 	mac_82557_D100_C  = 2,
> 	mac_82558_D101_A4 = 4,
> 	mac_82558_D101_B0 = 5,
> 	mac_82559_D101M   = 8,
> 	mac_82559_D101S   = 9,
> 	mac_82550_D102    = 12,
> 	mac_82550_D102_C  = 13,
> 	mac_82550_D102_E  = 15,
> 	mac_unknown       = 0xFF,
> };

Nice for matching the D10* names with chip numbers.

-- 
Regards,
Rask Ingemann Lambertsen

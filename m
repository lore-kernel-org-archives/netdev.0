From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: PROBLEM: usbnet / ax88179_178a: Panic in usb_hcd_map_urb_for_dma
Date: Fri, 17 Jan 2014 14:46:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45EDC1@AcuExch.aculab.com>
References: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w@mail.gmail.com>
	<1389385824.2025.95.camel@bwh-desktop.uk.level5networks.com>
	<87ob3j1ocb.fsf@nemi.mork.no>
	<CAHNSM4KU8QEybpHgAcCjQoWuRjU8=wd1O7KUVMnrRJKQ-xr=Gg@mail.gmail.com>
	<87zjn3z6d5.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D458FEE@AcuExch.aculab.com>
	<87zjn086iz.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D45904D@AcuExch.aculab.com>
	<87vbxo83wp.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D4590AF@AcuExch.aculab.com>
 <CACVXFVOGxWe5+o0hLROiPN43OCDekV2Ovz1yXr95H1m+yHGn4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: =?Windows-1252?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Thomas Kear <thomas@kear.co.nz>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: 'Ming Lei' <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44527 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750937AbaAQOsk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 09:48:40 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11246-01 for <netdev@vger.kernel.org>;
 Fri, 17 Jan 2014 14:48:38 +0000 (GMT)
In-Reply-To: <CACVXFVOGxWe5+o0hLROiPN43OCDekV2Ovz1yXr95H1m+yHGn4w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei
> On Mon, Jan 13, 2014 at 9:26 PM, David Laight <David.Laight@aculab.com> wrote:
> >>
> >> I believe all processing use the urb->num_sgs field to limit the number
> >> of entries.  Common interfaces like dma_map_sg() and for_each_sg() limit
> >> their processing to "nents" entries, and the USB code use the value of
> >> urb->num_sgs for this parameter.
> >
> > Which mostly means that the sg_xxx functions are doing a whole load
> > of unnecessary instructions and memory accesses...
> >
> > This probably has a lot to do with the significant difference in the
> > cpu use for the usb3 and 'normal' ethernet interfaces.
> >
> > While each bit doesn't seem significant, they soon add up.
> 
> If you plan to remove the 'nents' parameter, I am wondering if it is
> a good idea, because sg_nents() should be more heavy. Not mention
> sometimes the callers just want to map/unmap part of entries.

I was thinking of using a simple address/length array without all
the extra fields and flags 'overpunched' in the low address bits.

I'm not even sure the current use is strictly correct.
The field names of the scatterlist have a page address and offset
but the buffers passed to xhci (at least by usbnet) can span multiple
pages - they are physically contiguous.

IIRC some traces of requests for USB disks show a separate SG entry
for each 4k page - even for both virtually and physically adjacent
pages.

	David

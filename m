From: Jeremy Jackson <jerj@coplanar.net>
Subject: Re: adding tcpdump/OAM support to usb ATM devices
Date: Mon, 28 Apr 2008 11:54:42 -0400
Message-ID: <1209398082.8768.257.camel@ragnarok>
References: <200804281418.m3SEImnN032542@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.coplanar.net ([70.47.139.2]:53518 "EHLO
	titan.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933996AbYD1Pyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 11:54:49 -0400
In-Reply-To: <200804281418.m3SEImnN032542@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-04-28 at 10:18 -0400, Chas Williams (CONTRACTOR) wrote:
> In message <1209331913.8768.214.camel@ragnarok>,Jeremy Jackson writes:
> >who cares about ATM?  Well anyone using ADSL/2/2+ high speed internet
> >access is stuck with it, and that's not a small number of people.
> 
> i still care.

good to hear!  I'd love to label ATM as legacy and forget it... but
we're stuck with ATM on ADSL (VDSL has packet mode with HDLC-like
framing) since no hardware vendor has implemented the packet mode for
ADSL2/2+ even though it's part of the spec.

> >The question: what is the recommended way to push the captured cells to
> >userspace?  raw ATM socket, netlink, packet socket, i'm not up to speed
> >here people!
> 
> the right way is netlink.  i have some patches to add more complete
> oam support but they use the current ioctl interface which should be
> considered deprecated.  so adding new functionality using this interface
> to the kernel, would likely be rejected.

Can you send me some patches?  It would be good for discussion and
experimentation.

> eventually, all the atm clients (zeppelin, atmsigd, et al) should be
> converted to using netlink.
> 
> >in 2.6.22 drivers/usb/atm/usbatm.c::usbatm_extract_one_cell()
> >
> >cells received for open PVC/SVC sockets are processed, however OAM cells
> >are dropped, and cells to unbound VPI/VCI are dropped.
> >
> >This seems the likely place to route cells somewhere useful, but what
> >mechanism to use?
> 
> i guess now might be the time to try to define a netlink interface
> between the userspace and the kernel.

I think there are 2 cases, packet socket support for ATM, for
libpcap/tcpdump etc, and control functions (presently ioctl) switched to
use netlink.  Generating OAM cells might belong to a control function on
netlink, but I wonder about PF_RAWATM, the present setup with pcv/svc
sockets is a bit wierd, you set the qos type to AAL0 to mean raw.
Perhaps there should be a PF_RAWATM instead.

-- 
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net


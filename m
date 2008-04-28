From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: adding tcpdump/OAM support to usb ATM devices
Date: Mon, 28 Apr 2008 10:18:48 -0400
Message-ID: <200804281418.m3SEImnN032542@cmf.nrl.navy.mil>
References: <1209331913.8768.214.camel@ragnarok>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: Jeremy Jackson <jerj@coplanar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:46505 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933075AbYD1OTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 10:19:17 -0400
In-reply-to: <1209331913.8768.214.camel@ragnarok>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1209331913.8768.214.camel@ragnarok>,Jeremy Jackson writes:
>who cares about ATM?  Well anyone using ADSL/2/2+ high speed internet
>access is stuck with it, and that's not a small number of people.

i still care.

>The question: what is the recommended way to push the captured cells to
>userspace?  raw ATM socket, netlink, packet socket, i'm not up to speed
>here people!

the right way is netlink.  i have some patches to add more complete
oam support but they use the current ioctl interface which should be
considered deprecated.  so adding new functionality using this interface
to the kernel, would likely be rejected.

eventually, all the atm clients (zeppelin, atmsigd, et al) should be
converted to using netlink.

>in 2.6.22 drivers/usb/atm/usbatm.c::usbatm_extract_one_cell()
>
>cells received for open PVC/SVC sockets are processed, however OAM cells
>are dropped, and cells to unbound VPI/VCI are dropped.
>
>This seems the likely place to route cells somewhere useful, but what
>mechanism to use?

i guess now might be the time to try to define a netlink interface
between the userspace and the kernel.

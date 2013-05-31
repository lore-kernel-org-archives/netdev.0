From: <Narendra_K@Dell.com>
Subject: Re: Generic interface to make physical port number used by a
 netdevice available to user space
Date: Fri, 31 May 2013 05:13:16 -0700
Message-ID: <20130531121201.GA1311@fedora-17-guest.blr.amer.dell.com>
References: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
 <20130523093421.3b20a0bd@nehalam.linuxnetplumber.net>
 <E31FB011129F30488D5861F383904915210B96144A@BLRX7MCDC201.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:3996 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755105Ab3EaMNl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 08:13:41 -0400
In-Reply-To: <E31FB011129F30488D5861F383904915210B96144A@BLRX7MCDC201.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 27, 2013 at 06:39:00PM +0530, Narendra_K@Dell.com wrote:
> 
> > -----Original Message-----
> > From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> > Sent: Thursday, May 23, 2013 10:04 PM
> > To: K, Narendra
> > Cc: netdev@vger.kernel.org
> > One idea would be to reuse the mostly outdated if_port field.
> > As far as I can see only drivers using it are legacy drivers which support
> AUI vs.
> > TP back in the old bad days of BNC Ethernet.
> 
> Hi Stephen, thank you.
> 
> I think if_port or dev_id would be fine. The difference seems to be  that
> dev_id is already exported to sysfs.
> 

I think the following options could be explored -

1. dev_id:
Do not initialize it to -1, but use it to indicate physical port number
used by netdevice.

It is currently being used for indicating physical port number and
is also being used to differentiate OS instances as noted here.
http://marc.info/?l=linux-netdev&m=136992115300526&w=2

2. if_port:

Reuse if_port to indicate physical port number used by a netdevice as
suggested.

A quick look at the sources seems to indicate that it is also
being used to indicate the physical port number and data transfer mode.

Used to indicate physical port number by
	-drivers/net/ethernet/chelsio/cxgb/cxgb2.c
	-drivers/net/ethernet/tehuti/tehuti.c

Used to indicate data transfer mode by
	-drivers/net/ethernet/realtek/atp.c

Also, 'if_port' seems to be available to userspace via 
	-netlink (by rtnl_dump_ifinfo in net/core/rtnetlink.c)
	-SIOCGIFMAP ioctl

3. Add a new field 'physport' to 'struct net_device' and export it to sysfs.

It would be great to know your thoughts on which of the above would be
preferable.

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.

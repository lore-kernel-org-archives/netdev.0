From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] Use firmware provided index to register a network interface
Date: Thu, 23 Sep 2010 21:20:57 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE6A0AFD@blrx3m08.blr.amer.dell.com>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com> <20100922192228.GB29899@kroah.com> <EDA0A4495861324DA2618B4C45DCB3EE6A0AF8@blrx3m08.blr.amer.dell.com> <20100923152730.GA1261@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Vijay_Nijhawan@Dell.com>
To: <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:51709 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab0IWPvG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 11:51:06 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100923152730.GA1261@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Greg KH [mailto:greg@kroah.com]
> Sent: Thursday, September 23, 2010 8:58 PM
> To: K, Narendra
> Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org; linux-
> pci@vger.kernel.org; Domsch, Matt; Rose, Charles; Hargrave, Jordan;
> Nijhawan, Vijay
> Subject: Re: [PATCH] Use firmware provided index to register a network
> interface
> 
> > >
> > > Ick, again, what's wrong with using udev for this as it is
designed
> > to?
> > > That way no kernel changes are needed, and no one has to rely on
> the
> > > BIOS getting the firmware number right (meaning it will work on
all
> > > types of systems.)
> > >
> >
> > 1. We tried addressing this issue using udev only and without any
> kernel
> > changes, during Nov-Dec 2008 timeframe using Biosdevname udev helper
> > utility. Biosdevname utility has the ability to suggest BIOS
intended
> > name of an interface given its OS name.
> >
> > /sbin/biosdevname -I eth2 - (OS name)
> > eth0 - (Name according to the BIOS)
> >
> > KERNEL!="eth*", GOTO="biosdevname_end"
> > ACTION!="add",  GOTO="biosdevname_end"
> > NAME=="?*",     GOTO="biosdevname_end"
> >
> > PROGRAM="/sbin/biosdevname --policy=all_ethN -i %k",
> > ENV{INTERFACE_NAME}="%c"
> >
> > LABEL="biosdevname_end"
> >
> > We observed that renames in the same namespace, which is ethN
> namespace,
> > resulted in interface names like eth_rename_ren. The solution was
> > susceptible to driver load order. Please refer to this bug report-
> > https://bugzilla.novell.com/show_bug.cgi?id=441079.
> >
> > This solution was not favored.
> 
> That's because for some reason you don't want to accept the fact that
> if
> you want to rename things in a persistant manner, you have to do so in
> a
> namespace that is outside of the kernel's normal one.
> 
> Now trying to change the kernel namespace itself seems like a bad hack
> around this fact.
> 

The patch does not change the existing kernel name space. It adheres to
the existing ethN name space with IFNAMSIZ length requirements. The
patch only makes sure that eth0 always corresponds to what is labeled as
'Gb1' on server chassis, on systems where SMBIOS type 41 record is
available. And removes the need for any renames for the interfaces which
have a firmware index assigned by system firmware, as the very first
name assigned by the kernel will be as expected and deterministic.

With regards,
Narendra K







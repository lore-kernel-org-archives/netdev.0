From: <Shyam_Iyer@Dell.com>
Subject: RE: Question w.r.t debugfs / netdevice pass-through IOCTL
Date: Mon, 25 Oct 2010 06:48:28 -0700
Message-ID: <DBFB1B45AF80394ABD1C807E9F28D1570262CCC3BD@BLRX7MCDC203.AMER.DELL.COM>
References: <F363E7AC84E1B646A0358B281A46F4AEABA0FFCC68@HQ1-EXCH03.corp.brocade.com>
 <20101020211900.79b8336f@nehalam> <4CC0A0E9.9090903@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <ddutt@Brocade.COM>, <netdev@vger.kernel.org>
To: <john.r.fastabend@intel.com>, <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:17529 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465Ab0JYNta convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 09:49:30 -0400
In-Reply-To: <4CC0A0E9.9090903@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of John Fastabend
> Sent: Thursday, October 21, 2010 4:22 PM
> To: Stephen Hemminger
> Cc: Debashis Dutt; netdev@vger.kernel.org
> Subject: Re: Question w.r.t debugfs / netdevice pass-through IOCTL
> 
> On 10/20/2010 9:19 PM, Stephen Hemminger wrote:
> > On Wed, 20 Oct 2010 20:26:50 -0700
> > Debashis Dutt <ddutt@Brocade.COM> wrote:
> >
> >> Hi,
> >>
> >> For the Brocade 10G Ethernet driver (bna) we want to implement a set of operations which is not
> supported by current tools like ethtool.
> >>
> >> Examples of such operations would be
> >>        a) Queries related to CEE, if the link is CEE.
> 
> Assuming CEE is Converged Enhanced Ethernet here.
> 
> For CEE queries please consider using the dcbnl interface in /net/dcb/dcbnl.c. If
> it is missing an interface that would be useful to all DCB devices we could
> entertain adding it. Also this way DCB queries will work with existing tools that
> query these things lldpad/dcbtool.
> 
> The things you would want to know about a CEE device should be about the same
> regardless of the hardware in use lets try to use a single interface and avoid
> private interfaces.

John - I agree on this.. On a sidenote I would like the interface to not be netdev device specific.. 
View the CEE device to be not just an Ethernet controller but a SCSI controller as well and hence if this interface can be generally accessible by other subsystems.

> 
> Thanks,
> John.
> 
> >>        b) Get traces from firmware.
> >
> >>
> >> I was wondering what would be right approach to take here:
> >>                 a) use debugfs (like the Chelsio cxgb4 driver)
> > Works as long as they are really debug operations. The debugfs isn't always
> > available, and support should be a config option for your driver.
> >
> >>                 b) use SIOCDEVPRIVATE for the pass through IOCTL defined in
> >>                     struct net_device_ops{}
> >
> > The problem with ioctl is it doesn't work for 32 bit user space
> > compatiablity. The ioctl compat layer does not have enough context
> > to translate SIOCDEVPRIVATE
> >
> >>                     As per comments in the header file, b) should not be used
> >>                     since this IOCTL is supposed to be deprecated.
> >>                 c) use procfs / sysfs (these may not scale, in our opinion)
> >
> > Although less common, there were drivers putting things in /proc/net/xxx/ethX
> >
> >
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

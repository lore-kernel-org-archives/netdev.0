From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 8/9] netconsole: Update documentation for dynamic
 reconfigurability
Date: Thu, 5 Jul 2007 19:25:18 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707051913001.19842@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110819.28520.50445.sendpatchset@cselinux1.cse.iitk.ac.in>
 <468CEAEC.7040102@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:37872 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756298AbXGENdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 09:33:55 -0400
In-Reply-To: <468CEAEC.7040102@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Keiichi,

On Thu, 5 Jul 2007, Keiichi KII wrote:
> Hi Satyam,
> 
> > + cat enabled				# check if enabled is 1
> > + echo 0 > enabled			# disable the target (if required)
> > + echo eth2 > dev_name			# set local interface
> 
> I think that the above line should change from "echo eth2 > dev_name" to 
> "echo -n eth2 > dev_name" or the newline should be removed at store_dev_name().
> The default behavior of echo(1) outputs the newline. 
> So, if we write appropriate network device name to dev_name, 
> the netpoll can't find net_device in netpoll_setup(). 

Yes, you're right. I'll fix this in store_dev_name() itself, it isn't
right to limit users to only -n option. Thanks for pointing this out.

[ BTW I also noticed a typo in that file just above your extract that
mentions dev_name as a read-only attribute! That also must be fixed ... ]

> I don't have enough time now. So I will check your patches more specific 
> at the weekend.

Ok, thanks a lot. I'll wait for your comments / testing results over the
weekend, before sending out the next iteration.

BTW I did some testing myself, and have found another *embarrassing* bug:
if netconsole is loaded _without_ specifying any "netconsole=" parameter,
module is still kept loaded, but on unloading configfs_unregister_...()
obviously panics! :-) This should've been found by me earlier, just that
I never tested without specifying the parameter to modprobe :-(

Thanks,
Satyam

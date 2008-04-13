From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: arcnet - weird printk arc%d
Date: Sat, 12 Apr 2008 18:17:21 -0700
Message-ID: <20080412181721.34d50f0b@extreme>
References: <236742536@web.de>
	<48015CC8.4000004@isomerica.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: devzero@web.de, netdev@vger.kernel.org
To: dpn@isomerica.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:51383 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753683AbYDMBR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 21:17:28 -0400
In-Reply-To: <48015CC8.4000004@isomerica.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Apr 2008 21:07:20 -0400
Dan Noe <dpn@isomerica.net> wrote:

> devzero@web.de wrote:
> > Apr 13 01:25:50 neo klogd:  arc%d: Given: node 00h, shmem 0h, irq 0
> > Apr 13 01:25:50 neo klogd:  arc%d: No autoprobe for RIM I; you must specify the shmem and irq!
> > Apr 13 01:25:50 neo klogd:  arc%d: No autoprobe for IO mapped cards; you must specify the base address!
> > 
> > arc%d looks weird - is this intenitonal ?
> 
> The %d is normally replaced by the interface number after 
> register_netdev is called.  But these error messages are printed in 
> arcrimi_found() *before* register_netdev() is called (because the device 
> hasn't been found yet).
> 
> I'm not sure what the best approach to fixing this is.  Most likely the 
> log printouts at that point should not be using the macros that rely on 
> dev->name being fully correct.
> 
> Cheers,
> Dan
> 

use dev_info et al, to print out using the bus id.

From: Dan Noe <dpn@isomerica.net>
Subject: Re: arcnet - weird printk arc%d
Date: Sat, 12 Apr 2008 21:07:20 -0400
Message-ID: <48015CC8.4000004@isomerica.net>
References: <236742536@web.de>
Reply-To: dpn@isomerica.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: devzero@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from colobus.isomerica.net ([216.93.242.10]:57127 "EHLO
	colobus.isomerica.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683AbYDMBHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 21:07:22 -0400
In-Reply-To: <236742536@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devzero@web.de wrote:
> Apr 13 01:25:50 neo klogd:  arc%d: Given: node 00h, shmem 0h, irq 0
> Apr 13 01:25:50 neo klogd:  arc%d: No autoprobe for RIM I; you must specify the shmem and irq!
> Apr 13 01:25:50 neo klogd:  arc%d: No autoprobe for IO mapped cards; you must specify the base address!
> 
> arc%d looks weird - is this intenitonal ?

The %d is normally replaced by the interface number after 
register_netdev is called.  But these error messages are printed in 
arcrimi_found() *before* register_netdev() is called (because the device 
hasn't been found yet).

I'm not sure what the best approach to fixing this is.  Most likely the 
log printouts at that point should not be using the macros that rely on 
dev->name being fully correct.

Cheers,
Dan

-- 
                     /--------------- - -  -  -   -   -
                     |  Dan Noe
                     |  http://isomerica.net/~dpn/

From: Harry Coin <hcoin@n4comm.com>
Subject: Re: e100.c patch to 2.6.18 fixing Wake on Lan (WOL)
Date: Mon, 15 Jan 2007 13:24:21 -0600
Message-ID: <4.3.2.7.2.20070115131516.01ce9ec0@www.n4comm.com>
References: <4.3.2.7.2.20070115113616.03dcf4a8@www.n4comm.com>
 <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
 <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
 <4.3.2.7.2.20070115113616.03dcf4a8@www.n4comm.com> <45ABC5AA.1060307@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail14h.g14.rapidsite.net ([128.121.64.110]:47651 "HELO
	mail14h.g14.rapidsite.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751407AbXAOTYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 14:24:34 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <45ABC5AA.1060307@intel.com>
References: <4.3.2.7.2.20070115113616.03dcf4a8@www.n4comm.com>
 <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
 <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com>
 <4.3.2.7.2.20070115113616.03dcf4a8@www.n4comm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 10:19 AM 1/15/2007 -0800, Auke Kok wrote:
>Have you tried the version in 2.6.19?

I even tried copying and pasting the e100_down and the latest PM stuff from 
the newest e100.c version on sourceforge.   I admit to being defeated as to 
how to join a sourceforge group.   Too many hours writing Microsoft 
drivers  maybe?

It comes down to this:

1)  The e100_configure command is the only place that turns off the WOL 
disable bit.

2)  That bit is only turned off if e100_configure is called after 
netif_running is false and wol is set.

3)  e100_configure is not called at any point after dev->stop (the first 
moment netif_running is false) through the end of .shutdown.  Therefore WOL 
disable is always turned on, no matter the request by ethtools.

I sense there is a sense that if pci_enable_wake has been called properly, 
then all's well.   But on this board, there is a configuration bit that 
also has to be disabled, a but that is silently reset during a hw_reset, 
and hw_reset   __is__ called in e100_down.

Hence, the fix I submitted.   I know it isn't perfect because I'm not 
intimately familiar with the dynamics of this chip.   But I do know this:

14 Dell Optiplex systems failed to WOL with the stock 2.6.18 distributed 
with debian etch.   After my patch is applied to e100.c, and no other 
changes from anything default in 2.6.18 and debian etch, it works perfectly 
every time.   I should have added that ACPI and lapic are in use, but 
that's the usual case.

Cheers,

Harry Coin
N4 Communications
Bettendorf, Iowa


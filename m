From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e100.c patch to 2.6.18 fixing Wake on Lan (WOL)
Date: Mon, 15 Jan 2007 11:42:36 -0800
Message-ID: <45ABD92C.8090001@intel.com>
References: <4.3.2.7.2.20070115113616.03dcf4a8@www.n4comm.com> <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com> <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com> <4.3.2.7.2.20070115113616.03dcf4a8@www.n4comm.com> <4.3.2.7.2.20070115131516.01ce9ec0@www.n4comm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28198 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbXAOTmi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 14:42:38 -0500
To: Harry Coin <hcoin@n4comm.com>
In-Reply-To: <4.3.2.7.2.20070115131516.01ce9ec0@www.n4comm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Harry Coin wrote:
> At 10:19 AM 1/15/2007 -0800, Auke Kok wrote:
>> Have you tried the version in 2.6.19?
> 
> I even tried copying and pasting the e100_down and the latest PM stuff 
> from the newest e100.c version on sourceforge.   I admit to being 
> defeated as to how to join a sourceforge group.   Too many hours writing 
> Microsoft drivers  maybe?

the list is open to posting, so that's fairly easy.

> It comes down to this:
> 
> 1)  The e100_configure command is the only place that turns off the WOL 
> disable bit.
> 
> 2)  That bit is only turned off if e100_configure is called after 
> netif_running is false and wol is set.
> 
> 3)  e100_configure is not called at any point after dev->stop (the first 
> moment netif_running is false) through the end of .shutdown.  Therefore 
> WOL disable is always turned on, no matter the request by ethtools.
> 
> I sense there is a sense that if pci_enable_wake has been called 
> properly, then all's well.   But on this board, there is a configuration 
> bit that also has to be disabled, a but that is silently reset during a 
> hw_reset, and hw_reset   __is__ called in e100_down.
> 
> Hence, the fix I submitted.   I know it isn't perfect because I'm not 
> intimately familiar with the dynamics of this chip.   But I do know this:
> 
> 14 Dell Optiplex systems failed to WOL with the stock 2.6.18 distributed 
> with debian etch.   After my patch is applied to e100.c, and no other 
> changes from anything default in 2.6.18 and debian etch, it works 
> perfectly every time.   I should have added that ACPI and lapic are in 
> use, but that's the usual case.

okay, I don't necesary meant that your patch is incorrect, however we need to make sure 
that your patch doesn't break 2.6.19, because that code is already upstream.

on top of that, both patches might be needed, and I suspect that is the case to keep 
suspend and netconsole to keep working, so I would still like to ask you to test 2.6.19, 
with and without your patch.

I'll do the same here and push your patch to Garzik if (after testing) we're both OK 
with it.

Thanks,

Auke

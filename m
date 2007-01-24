From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.19.2 sky2/acpi crashes
Date: Wed, 24 Jan 2007 09:44:08 -0800
Message-ID: <20070124094408.600fd4e0@freekitty>
References: <1169542768.5537.11.camel@cocoduo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lionel Landwerlin <landwer@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46924 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752056AbXAXRqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 12:46:14 -0500
In-Reply-To: <1169542768.5537.11.camel@cocoduo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jan 2007 09:59:28 +0100
Lionel Landwerlin <landwer@free.fr> wrote:

> Hi,
> 
> I'm running a macbook with a Marvell ethernet controller, and I have a
> lots of freezes when using the ethernet controller under a load of
> ~100K/s. Since I'm running a 2.6.19.2 kernel, I'm able to get some
> report from the kernel. Here they are :

Please send sky2 bugs to me <shemminger@linux-foundation.org> and 
netdev@vger.kernel.org.

> I hope some fix could be released soon.

I get problem reports all the time, unfortunately, so far these have
not been reproducible on the configurations and hardware I have. I am
not denying there is a problem, but if I can't reproduce it, it takes
a long time to fix.

Your problem seems to be missed/lost interrupts. If you display
the contents of /proc/interrupts (ie cat /proc/interrupts), it
will show whether level (good), edge (bad) or MSI (good if hw works)
are being used.

Some workaround related things to try are:

1) Adding the module parameter "idle_timeout=10" will cause
the driver to poll for status every 10ms. This is obviously a performance
overhead but it can allow system to function.

2) Disabling MSI with either "pci=nomsi" on boot cmdline or by using
module parameter "disable_msi=1".  Message Signaled Interrupts are good,
but it seems some chipsets don't work right.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>

From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Driver for Solos PCI ADSL2+ card.
Date: Fri, 26 Dec 2008 12:44:23 +0000
Message-ID: <1230295463.4148.263.camel@macbook.infradead.org>
References: <20081226.012728.264387569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53895 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333AbYLZMo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 07:44:28 -0500
In-Reply-To: <20081226.012728.264387569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-26 at 01:27 -0800, David Miller wrote:
> Applied, but I don't need to tell you that this driver needs
> some work :)

Thanks. We'll be continuing to clean the driver up -- I have a card of
my own now, and should soon have a spare line to play with it without
having to disrupt my connectivity. One the way home from LCA I'll be
dropping in to Melbourne to see Traverse for a few days, and we should
get DMA working then.

One thing I'm not sure how to handle is the attributes. Currently we
expose a 'console' attribute file in sysfs. Reading parameters is done
by sending text to that:
	echo -en $$\\nParameterName\\n > /sys/.../console
	cat /sys/.../console

...and parameters are written by sending three lines of test:
	echo -en $$\\nParameterName\\nValue\\n > /sys/.../console
	cat /sys/.../console # to check for error

Currently, the kernel doesn't look at the request ID at all, and a
userspace program reading back from the file will receive _any_
responses and discard the ones it doesn't want.

We'll have to handle that properly, and we want to make the driver deal
with certain parameters for itself too -- like line speed and sync
status, which should be represented to the ATM layer.

I'm a little dubious about just exposing _all_ the parameters as
separate attribute files in sysfs though, because there are over 300 of
them. Maybe we could expose the _common_ ones like that, and have some
other interface which lets the user access others as required... but I
don't have strong opinions about how that latter interface should look.

One option is a character device which looks similar to the existing
interface. Or an ioctl, perhaps.

Another option is to let the user create attribute files in sysfs
dynamically, perhaps by echoing the desired parameter name to another
sysfs file.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation


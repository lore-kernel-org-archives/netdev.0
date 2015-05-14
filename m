From: Joe Perches <joe@perches.com>
Subject: Re: qla3xxx: Odd likely incorrect use of test_bit in qla3xxx.c
Date: Thu, 14 May 2015 01:22:57 -0700
Message-ID: <1431591777.2912.28.camel@perches.com>
References: <1431456145.2884.75.camel@perches.com>
	 <20150513131908.GB8431@mwanda> <1431538491.2912.14.camel@perches.com>
	 <20150514080116.GF8431@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0021.hostedemail.com ([216.40.44.21]:39343 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750893AbbENIXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 04:23:00 -0400
In-Reply-To: <20150514080116.GF8431@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 11:01 +0300, Dan Carpenter wrote:
> On Wed, May 13, 2015 at 10:34:51AM -0700, Joe Perches wrote:
> > In case the patches you found weren't of this type,
> > there are other possibly suspicious uses with & like:
> > drivers/usb/host/ehci-tegra.c:		set_bit((wIndex & 0xff) - 1, &ehci->suspended_ports);
> That's puzzling, yes, but my instinct without looking at the context is
> that it's probably valid.

It may be valid, but at a minimum it's bad code.

Assuming wIndex is guaranteed non-zero, it likely
should be something like:

(wIndex % BITS_PER_LONG) - 1

or suspended_ports should be more than a single ulong

Anyway, thanks.

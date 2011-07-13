From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 4/7] tg3: Determine PCI function number in one
 place
Date: Wed, 13 Jul 2011 21:13:27 +0100
Message-ID: <1310588008.2756.7.camel@bwh-desktop>
References: <1310585253-4817-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41479 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab1GMUNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 16:13:33 -0400
In-Reply-To: <1310585253-4817-5-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-13 at 12:27 -0700, Matt Carlson wrote:
> tg3 devices will need to know exactly what function number they are so
> that they can communicate their status to the other functions.  In a KVM
> environment, the function number of a device presented by the kernel
> might not be the true function number, so an alternative method to
> determine the function number is needed.
> 
> This patch used to contain an implementation for the alternative method,
> but recently we discovered a hardware bug that renders it incorrect.
> While new method is not yet known, it is still useful to consolidate the
> code that determines the PCI function to one location and use the
> results throughout the code.
[...]

Having run into (and thankfully fixed) a similar problem in sfc, I
wonder whether it would always be worthwhile to ask the hypervisor
maintainers to keep function numbers stable when passing-through
physical functions.  Any driver using PCI_FUNC() is likely to be broken
by function number changes, and 'git grep' shows there are quite a few
of them.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


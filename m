From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] [9/11] pasemi_mac: clear out old errors on interface
	open
Date: Wed, 3 Oct 2007 13:02:10 -0500
Message-ID: <20071003180210.GA19319@lixom.net>
References: <20071002212421.GA2282@lixom.net> <20071002212739.GJ2282@lixom.net> <4703D568.6000000@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:41039 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756367AbXJCR57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 13:57:59 -0400
Content-Disposition: inline
In-Reply-To: <4703D568.6000000@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 03, 2007 at 01:46:16PM -0400, Jeff Garzik wrote:
> Olof Johansson wrote:
>> pasemi_mac: clear out old errors on interface open
>> Clear out any pending errors when an interface is brought up. Since the 
>> bits
>> are sticky, they might be from interface shutdown time after firmware has
>> used it, etc.
>> Signed-off-by: Olof Johansson <olof@lixom.net>
>
> In general, interface-open should completely reset and initialize the 
> hardware.  does pasemi_mac not do that?

There's no explicit way to reset just one interface besides disabling it
(which we do at close, and re-enable at open). It seems that some of
the error bits are sticky across disable/enable, which is why this was
needed. Also, they're RW1C, so writing 0 doesn't remove them (need to
write 1 to clear).

The only other dependency from firmware at this time is the setting of mac
addresses, something that will be taken care of once we allow override of
them via ethtool, since we'd need to program them from the driver then
no matter what. Right now we assume that firmware has programmed it.


-Olof


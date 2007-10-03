From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [9/11] pasemi_mac: clear out old errors on interface
 open
Date: Wed, 03 Oct 2007 14:15:56 -0400
Message-ID: <4703DC5C.2030602@pobox.com>
References: <20071002212421.GA2282@lixom.net> <20071002212739.GJ2282@lixom.net> <4703D568.6000000@pobox.com> <20071003180210.GA19319@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59387 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753295AbXJCSP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 14:15:58 -0400
In-Reply-To: <20071003180210.GA19319@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> On Wed, Oct 03, 2007 at 01:46:16PM -0400, Jeff Garzik wrote:
>> Olof Johansson wrote:
>>> pasemi_mac: clear out old errors on interface open
>>> Clear out any pending errors when an interface is brought up. Since the 
>>> bits
>>> are sticky, they might be from interface shutdown time after firmware has
>>> used it, etc.
>>> Signed-off-by: Olof Johansson <olof@lixom.net>
>> In general, interface-open should completely reset and initialize the 
>> hardware.  does pasemi_mac not do that?
> 
> There's no explicit way to reset just one interface besides disabling it
> (which we do at close, and re-enable at open). It seems that some of
> the error bits are sticky across disable/enable, which is why this was
> needed. Also, they're RW1C, so writing 0 doesn't remove them (need to
> write 1 to clear).

OK just making sure, thanks.


> The only other dependency from firmware at this time is the setting of mac
> addresses, something that will be taken care of once we allow override of
> them via ethtool, since we'd need to program them from the driver then
> no matter what. Right now we assume that firmware has programmed it.

Standard procedure for this is

* upon module-load, obtain the MAC address from <whatever canonical source>
* upon interface-up, program dev->dev_addr[] into chip's RX filter (aka 
MAC address) registers

That permits the admin to override the MAC address via ifconfig. 
(ethtool doesn't support that, but you basically had the right idea)

	Jeff



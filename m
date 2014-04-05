From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net IPv6]: Fix maximum IPv6 address limit violation
Date: Sat, 5 Apr 2014 21:35:06 +0200
Message-ID: <20140405193506.GA27255@order.stressinduktion.org>
References: <533FEE9B.5090806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53042 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbaDETfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2014 15:35:08 -0400
Content-Disposition: inline
In-Reply-To: <533FEE9B.5090806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Sat, Apr 05, 2014 at 05:22:59PM +0530, Balakumaran Kannan wrote:
> Kernel doesn't check with max IPv6 address limit before adding IPv6 temporary
> address.
> 
> Security fix CVE-2013-0343 removes max_addresses check from ipv6_create_tempaddr
> function as this is handled before in addrconf_prefix_rcv function. But
> addrconf_prefix_rcv does max_addresses check only before adding MAC based RA
> address and if limit is already reached, it stops processing the prefix.
> 
> When IPv6 privacy extension is enabled, two addresses will be created for a
> new prefix received through RA. So if a machine has (max_addresses - 1) number
> of  IPv6 addresses, after receiving an RA with new prefix the machine will have
> (max_addresses + 1) number of IPv6 addresses.
> 
> So it is better to use a new prefix only if two IPv6 address slots available
> in case IPv6 privacy extension is enabled.

When I removed the check I did not think about any reason why the
max_addresses must count exact. It is merely there to prevent DoS attacks.
Is there a reason to revisit this? We don't care about locally added
addresses and I decided to do so for temporary addresses, too, because
only some small number will ever be generated for an autoconfigured one.

Actually when rolling over privacy addresses we generate new ones before
the old ones expire, so there could be more of those. This depends on
the setting of the timers.

IMHO we don't need this additional check and complexity or this there
a reason I don't currently see?

Thanks for the submission,

  Hannes

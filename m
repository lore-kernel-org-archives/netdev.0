From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ptp: increase the maximum number of clocks
Date: Thu, 21 Mar 2013 17:20:17 -0400 (EDT)
Message-ID: <20130321.172017.1499060411785395307.davem@davemloft.net>
References: <d219aa87bd5b3e2fa42449720d845a7110f642f0.1363893841.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3CUVUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:20:19 -0400
In-Reply-To: <d219aa87bd5b3e2fa42449720d845a7110f642f0.1363893841.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 21 Mar 2013 20:24:19 +0100

> As network adapters supporting PTP are becoming more common, machines with
> many NICs suddenly have many PHCs, too. Although the PHCs are not used in
> such cases, they produce error messages like this:
> 
> igb 0000:07:00.0: ptp_clock_register failed
> 
> Currently, the maximum number of devices accepted by ptp_clock_register
> is 8 which is pretty low. We could silence the error messages but this would
> hurt in case somebody wants to use one of the interfaces to actually run
> PTP, as the /dev/ptp%d device for the desired interface may or may not be
> available after each boot.
> 
> Let's increase the maximum to 128. This shouldn't be a problem, as for the
> char devices, the whole major number is reserved anyway, and 128bit bitmap
> isn't a big deal, either.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

This really needs to be dynamic, and it shows what a bad idea it was
to use character drivers for this which introduces arbitrary device
arity limitations.

I want to see a better solution to this problem than just bumping this
limit arbitrarily every once in a while.

I'm not apply this patch, we're better than this.

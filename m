From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] S390: Fix libphy link failure
Date: Mon, 06 May 2013 11:00:11 -0400 (EDT)
Message-ID: <20130506.110011.1813294677998011362.davem@davemloft.net>
References: <1367852019.4569.123.camel@chaos.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, heiko.carstens@de.ibm.com
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021Ab3EFPAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 11:00:15 -0400
In-Reply-To: <1367852019.4569.123.camel@chaos.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Mon, 06 May 2013 16:53:39 +0200

> On S390 basic IRQ functions are provided by the PCI subsystem, so
> code which calls these cannot be built if PCI support was not
> selected.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
> I know this isn't nice, but in the current state of S390 support
> this is all I can offer.

I really am tired of all of these special S390 dependencies.

You can't say this is a new problem, because we've been hitting this
issue repeatedly for more than a decade.  And I don't want to hear any
excuses, we've all already invested enough time into this to prove
that catering to S390's weird build limitations is a never ending
burdon for non-s390 people.

Really, our interfaces are abstract enough that every driver ought to
be buildable on every architecture.

It's time to put the burdon on your side, if you don't support some
IRQ interface or whatever, provide a stub that returns an error
rather than being that "special architecture" that everything else
has to specially cater for with ugly Kconfig dependencies.

Thanks.

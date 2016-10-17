From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] net: deprecate eth_change_mtu, remove
 usage
Date: Mon, 17 Oct 2016 13:25:53 -0400 (EDT)
Message-ID: <20161017.132553.1015830249902227215.davem@davemloft.net>
References: <20161017180027.4936fa15@jkicinski-Precision-T1700>
        <20161017.131513.135103913948374087.davem@davemloft.net>
        <20161017182049.4be802d1@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: kubakici@wp.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030392AbcJQRZz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:25:55 -0400
In-Reply-To: <20161017182049.4be802d1@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>
Date: Mon, 17 Oct 2016 18:20:49 +0100

> Hm.  I must be missing something really obvious.  I just booted
> net-next an hour ago and couldn't set MTU to anything larger than 1500
> on either nfp or igb.  As far as I can read the code it will set the
> max_mtu to 1500 in setup_ether() but none of the jumbo-capable drivers
> had been touched by Jarod so far...

Indeed.

Jarod, this doesn't work.

I guess the idea was that if the driver overrides ndo_change_mtu and
enforeced it's limits there, the driver would still work after your
changes.

But that isn't what is happening, look at the IGB example.

It uses ether_setup(), which sets those new defaults, but now when
the MTU is changed you enforce those default min/max before the
driver's ->ndo_change_mtu() has a change to step in front and make
the decision on it's own.

This means your changes pretty much did indeed break a lot of
drivers's ability to set larger than a 1500 byte MTU.

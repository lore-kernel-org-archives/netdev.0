From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/13] mac802154: at86rf230: add hw flags and
 merge ops
Date: Tue, 01 Jul 2014 23:14:07 -0700 (PDT)
Message-ID: <20140701.231407.1114227768498633408.davem@davemloft.net>
References: <1403980431-6201-1-git-send-email-alex.aring@gmail.com>
	<1403980431-6201-2-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	werner@almesberger.net
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbaGBGOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 02:14:08 -0400
In-Reply-To: <1403980431-6201-2-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Sat, 28 Jun 2014 20:33:39 +0200

> This patch adds new mac802154 hw flags for transmit power, csma and
> listen before transmit (lbt). These flags indicates that the transceiver
> supports these features. In ieee802154_register_device the callbacks are
> setted by hw flags instead of checking of null.
> 
> This patch merges also all at86rf230 operations into one operations structure
> and set the right hw flags for the at86rf230 transceivers.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>

I don't like this, now you've created a situation where a driver crash
is easy to introduce, ie. setting the capability flag but not providing
the operations pointer properly.

You have two choices:

1) Keep the pointer test mechanism

2) Add the flags, but validate the pointer at driver registration time
   and fail the register if the pointers for set flags are NULL.

When you fix this up, don't just submit this one patch, resubmit the
entire series.

Thank you.

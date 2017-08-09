From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: don't set __LINK_STATE_START until after
 dev->open() call
Date: Wed, 09 Aug 2017 14:24:37 -0700 (PDT)
Message-ID: <20170809.142437.1296296363845982866.davem@davemloft.net>
References: <20170807222421.11897-1-jacob.e.keller@intel.com>
        <20170808.181649.1810988621520678130.davem@davemloft.net>
        <02874ECE860811409154E81DA85FBB5882A3F62D@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752022AbdHIVYi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 17:24:38 -0400
In-Reply-To: <02874ECE860811409154E81DA85FBB5882A3F62D@ORSMSX115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Date: Wed, 9 Aug 2017 20:00:55 +0000

> That's what I am worried about. However, I think there are problems
> with leaving it. A lot of drivers rely on netif_running() to
> determine whether or not the device is open, but they may be using
> it relying on all the changes caused by the .ndo_open() handler are
> finished. The current system there is a race, since you set the
> __LINK_STATE_START before .ndo_open is called.

I think this is only a half-accurate description.

What drivers want to know is if initialization phase X of ndo_open()
has completed.

And honestly it must be like this because this is what one would
use to guide the teardown during failure paths of ndo_open(), right?

So I would really rather drivers internally track this "I initialized
X" state, as most drivers do, rather than take the risk of changing
the netif_running() behavior which can impact ~500 drivers :-)

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 08 Sep 2016 17:39:11 -0700 (PDT)
Message-ID: <20160908.173911.654039844795411872.davem@davemloft.net>
References: <CAJD3hpUDTZiJQ4YMiCizcYBKw=GD6jZoww3GxYjmajSdn6CE=g@mail.gmail.com>
        <20160908.170443.533565891486140434.davem@davemloft.net>
        <CAJD3hpVDo+WVVM0cvcD2z8LzXrsyBPvPC1E72ETN_yG2rNaeLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jojy.varghese@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43138 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbcIIAjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:39:15 -0400
In-Reply-To: <CAJD3hpVDo+WVVM0cvcD2z8LzXrsyBPvPC1E72ETN_yG2rNaeLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jojy Varghese <jojy.varghese@gmail.com>
Date: Thu, 8 Sep 2016 17:35:08 -0700

> -  "dst-ifdown"  does not look correct since it will never release
> reference to loopback device.

The routes and packets in the namespace are purged and disappear when
the namespace goes down, and that's how all of the references to the
loopback device are decremented.

Nothing dst_ifdown() does looks wrong, we are quite sure the problem
is elsewhere.

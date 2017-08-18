From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] about net: Fix inconsistent teardown and release of
 private netdev state.
Date: Thu, 17 Aug 2017 22:21:31 -0700 (PDT)
Message-ID: <20170817.222131.548007722474107806.davem@davemloft.net>
References: <1503009040.4936.161.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44270 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdHRFVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 01:21:32 -0400
In-Reply-To: <1503009040.4936.161.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Aug 2017 15:30:40 -0700

> So we do not really know if we need to clean up or not.

We always know, the answer is that whenever register_netdev() fails we
never need to perform any cleanup which is done by priv_destructor.

> Any idea how to fix the issue ?

Your patch is exactly how we should fix this, but without the comment.
The logic is straightforward.

If register_netdevice() fails any resources handled by priv_destructor
are cleaned up, it is guaranteed.

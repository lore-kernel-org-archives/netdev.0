From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 0/5] link-status fixes for mii-monitoring
Date: Mon, 27 Mar 2017 21:12:10 -0700 (PDT)
Message-ID: <20170327.211210.674299237092414810.davem@davemloft.net>
References: <20170327183725.30565-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
        nikolay@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
        maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54800 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750827AbdC1EMM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 00:12:12 -0400
In-Reply-To: <20170327183725.30565-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Mon, 27 Mar 2017 11:37:24 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> The mii monitoring is divided into two phases - inspect and commit. The
> inspect phase technically should not make any changes to the state and
> defer it to the commit phase. However detected link state inconsistencies
> on several machines and discovered that it's the result of some
> inconsistent update to link states and assumption that you *always* get
> rtnl-mutex. In reality when trylock() fails to acquire rtnl-mutex, the
> commit phase is postponed until next mii-mon run. At the next round
> because of the state change performed in the previous inspect-run, this
> round does not detect any changes and would skip calling commit phase.
> This would result in an inconsistent state until next link event happens
> (if it ever happens).
> 
> During the the commit phase, it's always assumed that speed and duplex
> fetch is always successful, but that's always not the case. However the
> slave state is marked UP irrespective of speed / duplex fetch operation.
> If the speed / duplex fetch operation results in insane values for either
> of these two fields, then keeping internal link state UP is not going to
> provide fruitful results either.
> 
> Please see into individual patches for more details.

Looks good, series applied, thanks.

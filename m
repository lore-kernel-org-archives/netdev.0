From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Fri, 13 Jan 2017 12:10:01 -0500 (EST)
Message-ID: <20170113.121001.2197905484527884236.davem@davemloft.net>
References: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
        <20170113000700.GA1482@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        mhocko@kernel.org, 3chas3@gmail.com, andreyknvl@google.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50730 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbdAMRKD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:10:03 -0500
In-Reply-To: <20170113000700.GA1482@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 13 Jan 2017 01:07:00 +0100

> Were alloc_skb moved one level up in the call stack, there would be
> no need to use the new wait api in the subsequent page, thus easing
> pre 3.19 longterm kernel maintenance (at least those on korg page).
> 
> But it tastes a tad bit too masochistic.

Lack of error handling of allocation failure is always a huge red
flag.  We even long ago tried to do something like this for TCP FIN
handling.

It's dumb, it doesn't work.

Therefore I agree that the correct fix is to move the SKB allocation
up one level to vcc_sendmsg() and make it handle errors properly.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: hold tunnel socket when handling control
 frames in l2tp_ip and l2tp_ip6
Date: Tue, 28 Mar 2017 21:34:16 -0700 (PDT)
Message-ID: <20170328.213416.449917447965488852.davem@davemloft.net>
References: <5e9e60582739bc2b9def6c29abe071913632878a.1490707863.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41442 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751469AbdC2EeU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 00:34:20 -0400
In-Reply-To: <5e9e60582739bc2b9def6c29abe071913632878a.1490707863.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 28 Mar 2017 15:32:35 +0200

> The code following l2tp_tunnel_find() expects that a new reference is
> held on sk. Either sk_receive_skb() or the discard_put error path will
> drop a reference from the tunnel's socket.
> 
> This issue exists in both l2tp_ip and l2tp_ip6.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

You introduced this bug in commit:

====================
commit a3c18422a4b4e108bcf6a2328f48867e1003fd95
Author: Guillaume Nault <g.nault@alphalink.fr>
Date:   Tue Nov 29 13:09:45 2016 +0100

    l2tp: hold socket before dropping lock in l2tp_ip{, 6}_recv()
====================

Therefore you should make this clear with a proper "Fixes: " tag
such as:

Fixes: a3c18422a4b4 ("l2tp: hold socket before dropping lock in l2tp_ip{, 6}_recv()")

on a line right before your signoff.

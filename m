From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun: fix premature POLLOUT notification on tun
 devices
Date: Mon, 13 Mar 2017 22:01:22 -0700 (PDT)
Message-ID: <20170313.220122.1218068190297475298.davem@davemloft.net>
References: <20170312230026.4632-1-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, bjorn@mork.no, Valdis.Kletnieks@vt.edu,
        jonas@lippuner.ca, aszlig@redmoonstudios.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdCNFBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 01:01:24 -0400
In-Reply-To: <20170312230026.4632-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 13 Mar 2017 00:00:26 +0100

> aszlig observed failing ssh tunnels (-w) during initialization since
> commit cc9da6cc4f56e0 ("ipv6: addrconf: use stable address generator for
> ARPHRD_NONE"). We already had reports that the mentioned commit breaks
> Juniper VPN connections. I can't clearly say that the Juniper VPN client
> has the same problem, but it is worth a try to hint to this patch.
> 
> Because of the early generation of link local addresses, the kernel now
> can start asking for routers on the local subnet much earlier than usual.
> Those router solicitation packets arrive inside the ssh channels and
> should be transmitted to the tun fd before the configuration scripts
> might have upped the interface and made it ready for transmission.
> 
> ssh polls on the interface and receives back a POLL_OUT. It tries to send
> the earily router solicitation packet to the tun interface.  Unfortunately
> it hasn't been up'ed yet by config scripts, thus failing with -EIO. ssh
> doesn't retry again and considers the tun interface broken forever.
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=121131
> Fixes: cc9da6cc4f56 ("ipv6: addrconf: use stable address generator for ARPHRD_NONE")
> Cc: Bjørn Mork <bjorn@mork.no>
> Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> Reported-by: Jonas Lippuner <jonas@lippuner.ca>
> Cc: Jonas Lippuner <jonas@lippuner.ca>
> Reported-by: aszlig <aszlig@redmoonstudios.org>
> Cc: aszlig <aszlig@redmoonstudios.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable.

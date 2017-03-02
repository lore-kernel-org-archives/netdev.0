From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: commit a52ad514fdf3b8a57ca4322c92d2d8d5c6182485 net: deprecate
 eth_change_mtu, remove usage breaks bonding on my machine
Date: Thu, 2 Mar 2017 11:17:08 -0800
Message-ID: <CAM_iQpVUuuix+cMdpeVkxyDqGKr8T1Qc3_jHTCDJ2SFfDKnVig@mail.gmail.com>
References: <0be1a70f-8593-ac8c-5f22-ee6676dfc672@fnarfbargle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jarod@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Brad Campbell <lists2009@fnarfbargle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34913 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751756AbdCBTY5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 14:24:57 -0500
Received: by mail-wr0-f194.google.com with SMTP id u108so6809473wrb.2
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 11:24:04 -0800 (PST)
In-Reply-To: <0be1a70f-8593-ac8c-5f22-ee6676dfc672@fnarfbargle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 1, 2017 at 8:11 AM, Brad Campbell <lists2009@fnarfbargle.com> wrote:
> G'day Jarod,
>
> I have a pair of machines that are linked by a pair of quad port e1000 cards
> with all 4 ports bonded. The network is configured with an mtu of 9000.
>
> Kernel 4.10 fails to bring these interfaces up as it fails when trying to
> set the mtu on the bond interface higher than 1500. A bisect between 4.9 &
> 4.10 winds up identifying this commit as where it all goes wrong. If I
> modify the network config to not touch the mtu (ie leave it at 1500) then it
> comes up ok.
>
> I can individually configure each port with an mtu of 9000, so the e1000
> driver is ok, but there appears to be breakage in the bonding driver related
> to your mtu api changes.
>
> I've just reverted to an older kernel, so it's no biggie. And as it's still
> a problem in the latest git head I assume nobody else has encountered it. I
> thought it worth reporting in case it triggers a quick lightbulb.

I think we need the following patch:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6321f12..de47006 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4179,6 +4179,7 @@ void bond_setup(struct net_device *bond_dev)

        /* Initialize the device entry points */
        ether_setup(bond_dev);
+       dev->max_mtu = ETH_MAX_MTU;
        bond_dev->netdev_ops = &bond_netdev_ops;
        bond_dev->ethtool_ops = &bond_ethtool_ops;

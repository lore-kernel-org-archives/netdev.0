From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net 1/3] vlan: Fix tcp checksums offloads for Q-in-Q vlan.
Date: Fri, 19 May 2017 10:04:20 +0900
Message-ID: <d58ec746-c9af-4cc5-f6e3-64c4c70200a6@lab.ntt.co.jp>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
 <1495114265-23368-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:55239 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752301AbdESBUJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 21:20:09 -0400
In-Reply-To: <1495114265-23368-2-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/05/18 22:31, Vladislav Yasevich wrote:
> It appears that since commit 8cb65d000, Q-in-Q vlans have been
> broken.  The series that commit is part of enabled TSO and checksum
> offloading on Q-in-Q vlans.  However, most HW we support can't handle
> it.  To work around the issue, the above commit added a function that
> turns off offloads on Q-in-Q devices, but it left the checksum offload.
> That will cause issues with most older devices that supprort very basic
> checksum offload capabilities as well as some newer devices (we've
> reproduced te problem with both be2net and bnx).
> 
> To solve this for everyone, turn off checksum offloading feature
> by default when sending Q-in-Q traffic.  Devices that are proven to
> work can provided a corrected ndo_features_check implemetation.
> 
> Fixes: 8cb65d000 ("net: Move check for multiple vlans to drivers")
> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

The patch looks ok, but why do you think 8cb65d000 is wrong?
The same check was there before my patch set.

kernel v4.0:
> netdev_features_t netif_skb_features(struct sk_buff *skb)
...
> 	if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD))
> 		features = netdev_intersect_features(features,
> 						     NETIF_F_SG |
> 						     NETIF_F_HIGHDMA |
> 						     NETIF_F_FRAGLIST |
> 						     NETIF_F_GEN_CSUM |
> 						     NETIF_F_HW_VLAN_CTAG_TX |
> 						     NETIF_F_HW_VLAN_STAG_TX);

The commit just moved the check into another function.


Toshiaki Makita

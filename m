From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH V3 net 1/3] vlan: Fix tcp checksum offloads in Q-in-Q
 vlans
Date: Wed, 24 May 2017 09:48:35 +0900
Message-ID: <603b7b7e-c424-c4ef-05e2-dc7768e6959a@lab.ntt.co.jp>
References: <1495561123-1819-1-git-send-email-vyasevic@redhat.com>
 <1495561123-1819-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com,
        Vladislav Yasevich <vyasevic@redhat.com>,
        Michal Kubecek <mkubecek@suse.cz>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:46332 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758246AbdEXAtK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 20:49:10 -0400
In-Reply-To: <1495561123-1819-2-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/05/24 2:38, Vladislav Yasevich wrote:
> It appears that TCP checksum offloading has been broken for
> Q-in-Q vlans.  The behavior was execerbated by the
> series
>     commit afb0bc972b52 ("Merge branch 'stacked_vlan_tso'")
> that that enabled accleleration features on stacked vlans.
> 
> However, event without that series, it is possible to trigger
> this issue.  It just requires a lot more specialized configuration.
> 
> The root cause is the interaction between how
> netdev_intersect_features() works, the features actually set on
> the vlan devices and HW having the ability to run checksum with
> longer headers.
> 
> The issue starts when netdev_interesect_features() replaces
> NETIF_F_HW_CSUM with a combination of NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM,
> if the HW advertises IP|IPV6 specific checksums.  This happens
> for tagged and multi-tagged packets.   However, HW that enables
> IP|IPV6 checksum offloading doesn't gurantee that packets with
> arbitrarily long headers can be checksummed.
> 
> This patch disables IP|IPV6 checksums on the packet for multi-tagged
> packets.
> 
> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> CC: Michal Kubecek <mkubecek@suse.cz>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---

Thank you for fixing it.
Acked-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Toshiaki Makita

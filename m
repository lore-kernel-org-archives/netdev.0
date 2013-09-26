From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 2/3] bonding: modify the old and add new
 xmit hash policies
Date: Thu, 26 Sep 2013 09:02:31 -0700
Message-ID: <1380211351.3165.189.camel@edumazet-glaptop>
References: <1380204582-27144-1-git-send-email-nikolay@redhat.com>
	 <1380204582-27144-3-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	fubar@us.ibm.com, vfalico@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34085 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab3IZQCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 12:02:34 -0400
Received: by mail-pd0-f175.google.com with SMTP id q10so1348487pdj.34
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 09:02:34 -0700 (PDT)
In-Reply-To: <1380204582-27144-3-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-26 at 16:09 +0200, Nikolay Aleksandrov wrote:
> This patch adds two new hash policy modes which use skb_flow_dissect:
> 3 - Encapsulated layer 2+3
> 4 - Encapsulated layer 3+4
> There should be a good improvement for tunnel users in those modes.
> It also changes the old hash functions to:
> hash ^= (__force u32)flow.dst ^ (__force u32)flow.src;
> hash ^= (hash >> 16);
> hash ^= (hash >> 8);
> 
> Where hash will be initialized either to L2 hash, that is
> SRCMAC[5] XOR DSTMAC[5], or to flow->ports which should be extracted
> from the upper layer. Flow's dst and src are also extracted based on the
> xmit policy either directly from the buffer or by using skb_flow_dissect,
> but in both cases if the protocol is IPv6 then dst and src are obtained by
> ipv6_addr_hash() on the real addresses. In case of a non-dissectable
> packet, the algorithms fall back to L2 hashing.
> The bond_set_mode_ops() function is now obsolete and thus deleted
> because it was used only to set the proper hash policy. Also we trim a
> pointer from struct bonding because we no longer need to keep the hash
> function, now there's only a single hash function - bond_xmit_hash that
> works based on bond->params.xmit_policy.
> 
> The hash function and skb_flow_dissect were suggested by Eric Dumazet.
> The layer names were suggested by Andy Gospodarek, because I suck at
> semantics.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> v2: fix a bug in bond_flow_dissect which might've caused the use of
>     uninitalized flow_keys and make use of skb_flow_get_ports
> v3: no change
> One line is intentionally left at 82 chars since it's the whole function
> and IMO looks better that way.
> 
>  drivers/net/bonding/bond_3ad.c   |   2 +-
>  drivers/net/bonding/bond_main.c  | 197 ++++++++++++++-------------------------
>  drivers/net/bonding/bond_sysfs.c |   2 -
>  drivers/net/bonding/bonding.h    |   3 +-
>  include/uapi/linux/if_bonding.h  |   2 +
>  5 files changed, 72 insertions(+), 134 deletions(-)


I love this patch, thanks for following up on this one.

Reviewed-by: Eric Dumazet <edumazet@google.com>

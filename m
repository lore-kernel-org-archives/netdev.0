From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5 2/3] bonding: modify the old and add new
 xmit hash policies
Date: Wed, 02 Oct 2013 05:03:06 -0700
Message-ID: <1380715386.19002.93.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380713966-3891-1-git-send-email-nikolay@redhat.com>
	 <1380713966-3891-3-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	fubar@us.ibm.com, vfalico@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34655 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495Ab3JBMDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 08:03:08 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so775197pdj.26
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 05:03:07 -0700 (PDT)
In-Reply-To: <1380713966-3891-3-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 13:39 +0200, Nikolay Aleksandrov wrote:
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

Very nice, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net 1/2] net/sched: act_vlan: Push skb->data to
 mac_header prior calling skb_vlan_*() functions
Date: Mon, 03 Oct 2016 21:42:24 -0400 (EDT)
Message-ID: <20161003.214224.2063102101117168185.davem@davemloft.net>
References: <1475140241-23586-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net,
        pshelar@ovn.org, jiri@mellanox.com
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52678 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbcJDBmf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 21:42:35 -0400
In-Reply-To: <1475140241-23586-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Thu, 29 Sep 2016 12:10:40 +0300

> Generic skb_vlan_push/skb_vlan_pop functions don't properly handle the
> case where the input skb data pointer does not point at the mac header:
> 
> - They're doing push/pop, but fail to properly unwind data back to its
>   original location.
>   For example, in the skb_vlan_push case, any subsequent
>   'skb_push(skb, skb->mac_len)' calls make the skb->data point 4 bytes
>   BEFORE start of frame, leading to bogus frames that may be transmitted.
> 
> - They update rcsum per the added/removed 4 bytes tag.
>   Alas if data is originally after the vlan/eth headers, then these
>   bytes were already pulled out of the csum.
> 
> OTOH calling skb_vlan_push/skb_vlan_pop with skb->data at mac_header
> present no issues.
> 
> act_vlan is the only caller to skb_vlan_*() that has skb->data pointing
> at network header (upon ingress).
> Other calles (ovs, bpf) already adjust skb->data at mac_header.
> 
> This patch fixes act_vlan to point to the mac_header prior calling
> skb_vlan_*() functions, as other callers do.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied and queued up for -stable.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net 2/2] net: skbuff: Limit skb_vlan_pop/push() to
 expect skb->data at mac header
Date: Mon, 03 Oct 2016 21:42:35 -0400 (EDT)
Message-ID: <20161003.214235.1262526925870231271.davem@davemloft.net>
References: <1475140241-23586-1-git-send-email-shmulik.ladkani@gmail.com>
        <1475140241-23586-2-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net,
        pshelar@ovn.org, jiri@mellanox.com
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52698 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbcJDBmh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 21:42:37 -0400
In-Reply-To: <1475140241-23586-2-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Thu, 29 Sep 2016 12:10:41 +0300

> skb_vlan_pop/push were too generic, trying to support the cases where
> skb->data is at mac header, and cases where skb->data is arbitrarily
> elsewhere.
> 
> Supporting an arbitrary skb->data was complex and bogus:
>  - It failed to unwind skb->data to its original location post actual
>    pop/push.
>    (Also, semantic is not well defined for unwinding: If data was into
>     the eth header, need to use same offset from start; But if data was
>     at network header or beyond, need to adjust the original offset
>     according to the push/pull)
>  - It mangled the rcsum post actual push/pop, without taking into account
>    that the eth bytes might already have been pulled out of the csum.
> 
> Most callers (ovs, bpf) already had their skb->data at mac_header upon
> invoking skb_vlan_pop/push.
> Last caller that failed to do so (act_vlan) has been recently fixed.
> 
> Therefore, to simplify things, no longer support arbitrary skb->data
> inputs for skb_vlan_pop/push().
> 
> skb->data is expected to be exactly at mac_header; WARN otherwise.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied.

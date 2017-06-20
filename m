From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC 1/2] net-next: fix DSA flow_disection
Date: Tue, 20 Jun 2017 13:17:38 +0300
Message-ID: <eb9691a5-04bf-6f69-a095-4609cbed2165@cogentembedded.com>
References: <20170620080655.7251-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:35656 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751078AbdFTKRl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 06:17:41 -0400
Received: by mail-lf0-f47.google.com with SMTP id p189so70855486lfe.2
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 03:17:41 -0700 (PDT)
In-Reply-To: <20170620080655.7251-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 6/20/2017 11:06 AM, John Crispin wrote:

> RPS and probably other kernel features are currently broken on some if not
> all DSA devices. The root cause of this that skb_hash will call the

   "Is" missing between "this" and "that"?

> flow_disector. At this point the skb still contains the magic switch header

   Dissector?

> and the skb->protocol field is not set up to the correct 802.3 value yet.
> by the time the tag specific code is called, removing the header and
> properly setting the protocol an invalid hash is already set. In the case
> of the mt7530 this will result in all flows always having the same hash.
>
> The patch adds 2 new fields to the dsa_switch_ops allowing the
> flow_disector to use them in order to be able to create the real hash of

   Again.

> the connection.
>
> Signed-off-by: John Crispin <john@phrozen.org>
[...]
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index fc5fc4594c90..da45bdf57408 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
[...]
> @@ -440,6 +441,17 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>  			 skb->vlan_proto : skb->protocol;
>  		nhoff = skb_network_offset(skb);
>  		hlen = skb_headlen(skb);
> +
> +		if (unlikely(netdev_uses_dsa(skb->dev))) {
> +			const struct dsa_switch_ops *ops;
> +			u8 *p = (u8 *) data;

     Didn't checkpatch.pl complain about space after (u8 *)?

> +
> +			ops = skb->dev->dsa_ptr->ds[0]->ops;
> +			if (ops->hash_proto_off)
> +				proto = (u16) p[ops->hash_proto_off];

    Again, didn't it?

[...]

MBR, Sergei

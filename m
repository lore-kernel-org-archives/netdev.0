From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: Allow raw buffers to be passed into the flow dissector.
Date: Mon, 25 Aug 2014 16:13:01 -0700
Message-ID: <CAHA+R7NTcRiOrP=M5=i8NkTHYZ3-RT8w-J5FPNsDh88c7yYKvQ@mail.gmail.com>
References: <20140823.121855.1259915921868754968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:54227 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983AbaHYXND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 19:13:03 -0400
Received: by mail-la0-f49.google.com with SMTP id hz20so13705694lab.8
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 16:13:01 -0700 (PDT)
In-Reply-To: <20140823.121855.1259915921868754968.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2014 at 12:18 PM, David Miller <davem@davemloft.net> wrote:
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 5f362c1..660c649 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -34,29 +34,40 @@ static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *i
>   * The function will try to retrieve the ports at offset thoff + poff where poff
>   * is the protocol port offset returned from proto_ports_offset
>   */
> -__be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto)
> +__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
> +                           void *data, int hlen)


You forgot to update the comments above __skb_flow_get_ports(),
not a big deal, I will send a patch if you don't. ;-)

Not sure if I read your patch correctly, I think our goal is to make
skb parameter
optional so that callers can pass NULL if they don't have a skb struct?
__skb_flow_dissect() still refers skb->protocol at least.


Thanks for the patch anyway.

From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v4 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Mon, 13 Apr 2015 17:57:21 -0700
Message-ID: <552C65F1.8010402@plumgrid.com>
References: <CAHA+R7PqC=cfb+WTrBrQjNkio9-bWXX9mX43xcRism4qTNiGog@mail.gmail.com>	<5528C4FC.5020207@iogearbox.net> <CAHA+R7N1oPoZBgtF0WOa=aXveT4T=26yfL73Temdp+qWxkxfug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36146 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153AbbDNA5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 20:57:23 -0400
Received: by pabsx10 with SMTP id sx10so119630399pab.3
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 17:57:23 -0700 (PDT)
In-Reply-To: <CAHA+R7N1oPoZBgtF0WOa=aXveT4T=26yfL73Temdp+qWxkxfug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/15 3:44 PM, Cong Wang wrote:
>
> My suggestion is fairly simple: move skb_pull() out of eth_type_trans()
> and move it to netif_receive_skb(), it apparently needs much more work
> but it worth the effort. This would eliminate the skb_push() in mirred
> and in ifb too, dev_forward_skb() would benefit too.

wow. That would be massive. We're talking months worth of work here.
Though theoretically it's possible, we'd still need a flag to preserve
compatibility with user space and to be able to roll such monster step
by step. Also non-eth devices are calling into netif_receive_skb(). Just
thinking about all corner cases of such move makes me very skeptical
that we can pull it off. In general we don't care about out of tree
drivers, but changing eth_type_trans() this way is really scary.
I'd rather keep things simple which is this patch.

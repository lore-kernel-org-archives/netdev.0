From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Thu, 09 Apr 2015 17:15:20 +0200
Message-ID: <55269788.4070206@iogearbox.net>
References: <1428535575-7736-2-git-send-email-ast@plumgrid.com>	<20150408.224404.1913719826015357860.davem@davemloft.net>	<5525EC69.1080606@plumgrid.com> <20150408.231456.1063648455572594170.davem@davemloft.net> <5525F48F.5030108@plumgrid.com> <55260C2F.608@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jiri@resnulli.us, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49753 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473AbbDIPPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 11:15:35 -0400
In-Reply-To: <55260C2F.608@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2015 07:20 AM, Alexei Starovoitov wrote:
...
> we cannot change the meaning of ld_abs, since for dgram sockets
> offset is actually not pointing to L2.
> af_packet is doing:
>   if (sk->sk_type != SOCK_DGRAM)
>        skb_push(skb, skb->data - skb_mac_header(skb));
>   res = run_filter(skb, sk, snaplen);
> so not everything assumes L2.

It would be not just that e.g. sock_queue_rcv_skb() users
have differing offset assumptions as well when they call
from their protocols into sk_filter().

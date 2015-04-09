From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Thu, 09 Apr 2015 08:36:38 -0700
Message-ID: <1428593798.25985.256.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428535575-7736-2-git-send-email-ast@plumgrid.com>
		<20150408.224404.1913719826015357860.davem@davemloft.net>
		<5525EC69.1080606@plumgrid.com>
	 <20150408.231456.1063648455572594170.davem@davemloft.net>
	 <5525F48F.5030108@plumgrid.com> <55260C2F.608@plumgrid.com>
	 <55269788.4070206@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	jiri@resnulli.us, jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37240 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755488AbbDIPgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 11:36:41 -0400
Received: by igblo3 with SMTP id lo3so67893389igb.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 08:36:40 -0700 (PDT)
In-Reply-To: <55269788.4070206@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-09 at 17:15 +0200, Daniel Borkmann wrote:
> On 04/09/2015 07:20 AM, Alexei Starovoitov wrote:
> ...
> > we cannot change the meaning of ld_abs, since for dgram sockets
> > offset is actually not pointing to L2.
> > af_packet is doing:
> >   if (sk->sk_type != SOCK_DGRAM)
> >        skb_push(skb, skb->data - skb_mac_header(skb));
> >   res = run_filter(skb, sk, snaplen);
> > so not everything assumes L2.
> 
> It would be not just that e.g. sock_queue_rcv_skb() users
> have differing offset assumptions as well when they call
> from their protocols into sk_filter().

It seems that passing an extra parameter
could help those users, and would remove the requirement
of skb_clone() from dev_queue_xmit_nit()

skb_clone() would only be done after run_filter()

Maybe we'll finally have a fast packet capture, instead of simply
focusing on the filter part, which is tiny.

Lets take this discussion as the incentive to finally get this done
right.

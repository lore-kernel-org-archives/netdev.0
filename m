From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 21:25:54 -0400
Message-ID: <517734A2.9060609@mojatatu.com>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>  <1366749094-5982-1-git-send-email-willemb@google.com>  <20130423142333.15479dfa@nehalam.linuxnetplumber.net>  <1366753063.8964.14.camel@edumazet-glaptop>  <20130423145222.5b696d0c@nehalam.linuxnetplumber.net> <1366762196.8964.46.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Willem de Bruijn <willemb@google.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:45424 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755281Ab3DXB0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 21:26:05 -0400
Received: by mail-ob0-f174.google.com with SMTP id wc20so1049148obb.19
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 18:26:03 -0700 (PDT)
In-Reply-To: <1366762196.8964.46.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-04-23 08:09 PM, Eric Dumazet wrote:

> qdisc code has a hardcoded dev_hard_start_xmit() call, thats why ifb
> hack is used. Not mentioning device flow control.
>
> It might be possible to use a q->xmit() method instead, so that it can
> be used on ingress without ifb.
>

If i understood correctly what you are trying to achieve:
I dont think one qdisc per rx queue/ring will work well in
presence of qdisc since the qdisc is attached per netdev.
i.e when packets are fanned out across cpu backlogs, as long
as they came in via same netdev queue, they are going to share
the same lock with all other cpus such packets have been fanned out to
the moment you attach an ingress qdisc to that netdev ring/queue.

One unorthodox approach is to have a qdisc per backlog queue
since the backlog is per cpu; given it is abstracted as a netdev,
it becomes a natural fit (sans the fact backlog queue is
unidirectional).

cheers,
jamal

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 18:32:31 -0700
Message-ID: <1366767151.8964.56.camel@edumazet-glaptop>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
	  <1366749094-5982-1-git-send-email-willemb@google.com>
	  <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
	  <1366753063.8964.14.camel@edumazet-glaptop>
	  <20130423145222.5b696d0c@nehalam.linuxnetplumber.net>
	 <1366762196.8964.46.camel@edumazet-glaptop> <517734A2.9060609@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Willem de Bruijn <willemb@google.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:38843 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755426Ab3DXBce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 21:32:34 -0400
Received: by mail-pd0-f182.google.com with SMTP id 3so789536pdj.13
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 18:32:34 -0700 (PDT)
In-Reply-To: <517734A2.9060609@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 21:25 -0400, Jamal Hadi Salim wrote:
> On 13-04-23 08:09 PM, Eric Dumazet wrote:
> 
> > qdisc code has a hardcoded dev_hard_start_xmit() call, thats why ifb
> > hack is used. Not mentioning device flow control.
> >
> > It might be possible to use a q->xmit() method instead, so that it can
> > be used on ingress without ifb.
> >
> 
> If i understood correctly what you are trying to achieve:
> I dont think one qdisc per rx queue/ring will work well in
> presence of qdisc since the qdisc is attached per netdev.

MQ permits to have one qdisc per TX queue.

It would be the same concept in ingress.

> i.e when packets are fanned out across cpu backlogs, as long
> as they came in via same netdev queue, they are going to share
> the same lock with all other cpus such packets have been fanned out to
> the moment you attach an ingress qdisc to that netdev ring/queue.
> 

Not sure what you mean. The qdisc stuff would replace the 'cpu backlog',
not be added to it. Think of having possibility to control backlog using
standard qdiscs, like fq_codel ;)

> One unorthodox approach is to have a qdisc per backlog queue
> since the backlog is per cpu; given it is abstracted as a netdev,
> it becomes a natural fit (sans the fact backlog queue is
> unidirectional).

Yes, but the per cpu backlog is shared for all devices. We probably want
different qdisc for gre tunnel, eth0, ...

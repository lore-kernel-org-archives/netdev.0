From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: use jump label patching for ingress qdisc
 in __netif_receive_skb_core
Date: Fri, 10 Apr 2015 18:41:17 -0700
Message-ID: <55287BBD.2030006@plumgrid.com>
References: <66b2c2faaa0f629dd9a8c0981bf51f6484bc4ee9.1428699635.git.daniel@iogearbox.net> <CAHA+R7PXy_kOn3pUOdGvU4L3n-EgH8cXNCmGQfaDQTUNaP2S4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33853 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841AbbDKBlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:41:19 -0400
Received: by pdbqa5 with SMTP id qa5so39793522pdb.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:41:19 -0700 (PDT)
In-Reply-To: <CAHA+R7PXy_kOn3pUOdGvU4L3n-EgH8cXNCmGQfaDQTUNaP2S4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/15 6:14 PM, Cong Wang wrote:
> So the following code is slow enough to deserve a static key
> optimization?
>
> struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
>
> if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
>      goto out;

It helps a little bit here and helps even more to my ingress_l2 patch
that is based on top of this one. Every cycle counts.

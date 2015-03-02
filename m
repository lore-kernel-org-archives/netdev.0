From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in
 sch_sfq
Date: Mon, 02 Mar 2015 11:24:38 -0800
Message-ID: <1425324278.5130.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	 <1425247789-21211-7-git-send-email-therbert@google.com>
	 <1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34044 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbbCBTYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:24:41 -0500
Received: by igal13 with SMTP id l13so18690795iga.1
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 11:24:40 -0800 (PST)
In-Reply-To: <CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-02 at 07:31 -0800, Tom Herbert wrote:

> As I already mentioned, the probability of skb_get_hash returning the
> same value for two flows is 1/2^32. I suspect it's greater probability
> to get a hash collision between two IPv6 flows with subtlety different
> addresses or simply match 4-tuples in different address spaces (like
> VLAN or with VNID). If hash collision is really a problem, we can
> periodically rekey skb->hash (either SW or HW) or maybe move to 64 bit
> hashes somehow. Anyway, we potentially have the same problem in RSS
> and other uses of the hash, if hashes collide then two flows share the
> same bucket forever unless there is an action to break that.

Main historical use of SFQ is for routers.

We do not control skb->hash for forwarding workload, unless you
reprogram RSS keys on the NIC.

If you remember, we used to have a problem on some NIC using a well
known RSS key. It is fortunate SFQ/fq_codel did not rely on skb->hash
too much.

If to target one flow, attackers need to attack your big boxes to flood
one particular RX queue at NIC level, this has a huge cost for them.

While targeting one hash bucket on a qdisc might be much easier, if they
know even a hash perturbation has no effect against their attack.

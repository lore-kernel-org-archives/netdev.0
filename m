From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in
 sch_sfq
Date: Mon, 02 Mar 2015 11:28:03 -0800
Message-ID: <1425324483.5130.115.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	 <1425247789-21211-7-git-send-email-therbert@google.com>
	 <1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
	 <CA+mtBx-Bhewd6Ez4OotWEhxvVO8rrOieWCGAnMa9vfhTbzj=yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:43641 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309AbbCBT2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:28:05 -0500
Received: by iebtr6 with SMTP id tr6so50726394ieb.10
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 11:28:04 -0800 (PST)
In-Reply-To: <CA+mtBx-Bhewd6Ez4OotWEhxvVO8rrOieWCGAnMa9vfhTbzj=yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2015-03-02 at 08:25 -0800, Tom Herbert wrote:

> One other possibility is that with the txhash changes we can rehash
> individual connections that are sourced from the host. I was planning
> to do this on too many TCP retransmits to try to get a different ECMP
> path (type of source routing), but we could also do this periodically
> or based on request from qdisc. ooo_okay could be taken into account
> to avoid OOO packets.

About locally generated traffic, skb->txhash potential uses would be

1) Somewhat spray txhash on the wire (Hmmm...)
   Hard to do that with regular IPv4/tcp traffic, or quite hacky.
   (like VLAN spraying...)

2.1) Slave selection on bonding driver
2.2) TX queue selection on multiqueue NIC.

    In this model (way different than XPS), then skb->ooo_okay is of
    no use :

    In both cases, if you change skb->txhash after congestion event,
    you do not care of reorders anyway. They are going to be generated
    most probably because of different paths.

From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in sch_sfq
Date: Mon, 2 Mar 2015 11:34:54 -0800
Message-ID: <CA+mtBx8sFBV4hFkdnvChuO0UaoN=XHKgVhreM5GwQXXgR9ARvg@mail.gmail.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	<1425247789-21211-7-git-send-email-therbert@google.com>
	<1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
	<CA+mtBx-Bhewd6Ez4OotWEhxvVO8rrOieWCGAnMa9vfhTbzj=yg@mail.gmail.com>
	<1425324483.5130.115.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:38280 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920AbbCBTez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:34:55 -0500
Received: by iecrd18 with SMTP id rd18so50826608iec.5
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 11:34:55 -0800 (PST)
In-Reply-To: <1425324483.5130.115.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 11:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> On Mon, 2015-03-02 at 08:25 -0800, Tom Herbert wrote:
>
>> One other possibility is that with the txhash changes we can rehash
>> individual connections that are sourced from the host. I was planning
>> to do this on too many TCP retransmits to try to get a different ECMP
>> path (type of source routing), but we could also do this periodically
>> or based on request from qdisc. ooo_okay could be taken into account
>> to avoid OOO packets.
>
> About locally generated traffic, skb->txhash potential uses would be
>
> 1) Somewhat spray txhash on the wire (Hmmm...)
>    Hard to do that with regular IPv4/tcp traffic, or quite hacky.
>    (like VLAN spraying...)
>
Spraying would be quite easy by modulating txhash from TCP and using
either  UDP encapsulation like GUE or IPv6 flow labels. Only problem
is that this would constantly be changing rxhash at the receiver for
the connection, although flow labels might 'just work' with IPv6
Toeplitz in NICs.

> 2.1) Slave selection on bonding driver
> 2.2) TX queue selection on multiqueue NIC.
>
>     In this model (way different than XPS), then skb->ooo_okay is of
>     no use :
>
>     In both cases, if you change skb->txhash after congestion event,
>     you do not care of reorders anyway. They are going to be generated
>     most probably because of different paths.
>
>
>

From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] netem: fix classful handling
Date: Wed, 28 Dec 2011 22:17:31 -0800
Message-ID: <20111228221731.4d4954a9@s6510.linuxnetplumber.net>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	<20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
	<1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
	<1324664907.2915.5.camel@edumazet-laptop>
	<20111223110749.7a690685@nehalam.linuxnetplumber.net>
	<1324668083.2915.15.camel@edumazet-laptop>
	<1325132760.2607.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42353 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163Ab1L2GRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 01:17:36 -0500
In-Reply-To: <1325132760.2607.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Dec 2011 05:26:00 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Commit 10f6dfcfde (Revert "sch_netem: Remove classful functionality")
> reintroduced classful functionality to netem, but broke basic netem
> behavior :
> 
> netem uses an t(ime)fifo queue, and store timestamps in skb->cb[]
> 
> If qdisc is changed, time constraints are not respected and other qdisc
> can destroy skb->cb[] and block netem at dequeue time.
> 
> Fix this by always using internal tfifo, and optionally attach a child
> qdisc to netem.
> 
> Example of use :
> 
> DEV=eth3
> tc qdisc del dev $DEV root
> tc qdisc add dev $DEV root handle 30: est 1sec 8sec netem delay 20ms 10ms
> tc qdisc add dev $DEV parent 30:0 sfq

Does it work with TBF which is a more useful option?

Also, the whole tfifo idea is only to support the wierd idea that
if doing random delay that packets should get reordered based on the
results of the random value; it was an behavior some users wanted
because that is what NISTnet did.

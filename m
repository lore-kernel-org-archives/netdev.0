From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next] netem: fix classful handling
Date: Thu, 29 Dec 2011 17:52:49 +0100
Message-ID: <20111229165249.GB2948@hell>
References: <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
 <1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
 <1324664907.2915.5.camel@edumazet-laptop>
 <20111223110749.7a690685@nehalam.linuxnetplumber.net>
 <1324668083.2915.15.camel@edumazet-laptop>
 <1325132760.2607.15.camel@edumazet-laptop>
 <20111228221731.4d4954a9@s6510.linuxnetplumber.net>
 <1325149922.2607.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:50413 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754673Ab1L2Qww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 11:52:52 -0500
Content-Disposition: inline
In-Reply-To: <1325149922.2607.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-12-29 10:12:02 [+0100]:

>> Also, the whole tfifo idea is only to support the wierd idea that
>> if doing random delay that packets should get reordered based on the
>> results of the random value; it was an behavior some users wanted
>> because that is what NISTnet did.
>
>tfifo supports a time ordered queuing, wich mimics some jitter in the
>network. This seems quite useful.
>
>I see what you suggest : adding 'time_to_send' in the generic qdisc cb.
>
>But it makes no sense if we attach a reordering qdisc, like SFQ :
>A 'high prio' packet will block the whole netem because we'll have to
>throttle since this packet time_to_send will be in the future, while
>many other elligible packets are in queue.

In other words netem jitter and a qdisc !tfifo will not work. Correct? The
rate extension also peak the last packet to get the reference time (assuming a
strict ordering):

[...]
now = netem_skb_cb(skb_peek_tail(list))->time_to_send;
[...]


We should avoid a different (unseeable) behavior depending on the queue
(tfifo, SFQ).  Another point: operate netem and qdisc on the same computer can
lead to timing abnormalities. In our test setups we operate qdisc/tcp/whatever
setups and netem on more then on computer.

Hagen

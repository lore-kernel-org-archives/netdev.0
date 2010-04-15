From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: Strange packet drops with heavy firewalling
Date: Thu, 15 Apr 2010 15:23:50 +0200
Message-ID: <m3633szw61.fsf@ursa.amorsen.dk>
References: <m339z50x1l.fsf@ursa.amorsen.dk>
	<q2v40c9f5b21004120116p766df82dj88c6af4e4cad55f@mail.gmail.com>
	<1271083479.2858.377.camel@ursa.amorsen.dk>
	<p2x40c9f5b21004120833jd7a749cak6ea69cebd28f8352@mail.gmail.com>
	<1271091990.2858.409.camel@ursa.amorsen.dk>
	<u2y412e6f7f1004121618p6d6eff30q8a45a03faa59a912@mail.gmail.com>
	<1271138186.16881.168.camel@edumazet-laptop>
	<m3hbnfzsye.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	zhigang gong <zhigang.gong@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:39394 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753203Ab0DONYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 09:24:00 -0400
In-Reply-To: <m3hbnfzsye.fsf@ursa.amorsen.dk> (Benny Amorsen's message of
	"Tue, 13 Apr 2010 09:56:25 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benny Amorsen <benny+usenet@amorsen.dk> writes:

> I'll keep monitoring the server, and if it starts dropping packets again
> or load increases I'll check whether irqbalanced does the right thing,
> and if not I'll implement your suggestion.

It did start dropping packets (although very few, a few packets dropped
at once perhaps every ten minutes). Irqbalanced didn't move the
interrupts.

Doing

echo 01 >/proc/irq/99/smp_affinity
echo 02 >/proc/irq/100/smp_affinity
echo 04 >/proc/irq/101/smp_affinity

and so on like Erik Dumazet suggested seems to have helped, but not
entirely solved the problem.

The problem now manifests itself this way in ethtool -S:
     rx_no_buffer_count: 270
     rx_queue_drop_packet_count: 270

I can't be sure that I'm not just getting hit by a 1Gbps traffic spike,
of course, but it is a bit strange that a machine which can do 200Mbps
at 92% idle can't handle subsecond peaks close to 1Gbps...

I wish ifstat could report errors so I could see what the traffic rate
was when the problem occurred...


/Benny

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: resurrecting tcphealth
Date: Sun, 15 Jul 2012 11:53:30 +0200
Message-ID: <1342346010.3265.10966.camel@edumazet-glaptop>
References: <dee325378a2d3b7792da9640fc14905f.squirrel@webmail.univie.ac.at>
	 <20120714144800.7f8c97f6@nehalam.linuxnetplumber.net>
	 <b93cddfd0a19158ec59823140d1e2075.squirrel@webmail.univie.ac.at>
	 <1342336597.3265.10617.camel@edumazet-glaptop>
	 <3e426bd471b8a54bfa5320f05e88e635.squirrel@webmail.univie.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Piotr Sawuk <a9702387@unet.univie.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39371 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab2GOJxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 05:53:36 -0400
In-Reply-To: <3e426bd471b8a54bfa5320f05e88e635.squirrel@webmail.univie.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-15 at 11:17 +0200, Piotr Sawuk wrote:
> On So, 15.07.2012, 09:16, Eric Dumazet wrote:
> > On Sun, 2012-07-15 at 01:43 +0200, Piotr Sawuk wrote:
> >
> >> oh, and again I recommend the really short although outdated thesis
> >>
> >> [1] https://sacerdoti.org/tcphealth/tcphealth-paper.pdf
> >
> > A thesis saying SACK are not useful is highly suspect.
> >
> > Instead of finding why they behave not so good and fix the bugs, just
> > say "SACK addition to TCP is not critical"
> the actual quotation is "We also found that the number of unnecessary
> duplicate packets were quite small potentially indicating that the SACK
> addition to TCP is not critical."
> >
> > Really ?
> 
> no, not really. he he actually said that SACK has been made mostly obsolete
> by "Linux 2.2 implements fast retransmits for up to two packet gaps, thus
> reducing the need for course grained timeouts due to the lack of SACK." and
> he was a bit more careful and admitted that further tests with tcphealth are
> needed to check if SACK really makes that big a difference. he admitted "It
> could be that SACK's advantage lies in other areas such as very large
> downloads or when using slow and unreliable network links." all these things
> could be checked again nowadays, with larger files available and wlan-users
> and higher traffic -- just find something without SACK...

There are hundred of papers about TCP behavior. Many are very good.

This one seems not the best of them by far, and is based on measures
done on 2001 (!!!), on a single computer (!!!), connected to a
particular ISP (!!!), using a wireless pcmcia network card. (!!!)

At that time, almost no clients were using SACK. Because windows 98/XP
dont negociate SACK by default (you need to tweak registry)

Its like saying ECN is useless : If ECN users are under 1 % of total
number of users, network is still under pressure and ECN benefits cannot
rise because of misbehavior of other flows.

With RTT of 100 ms, SACK are clearly a win for long transferts.

A single drop shall retransmit a single packet instead of ~500 packets.
Only fools could deny this fact. Studying DuplicateAcks to detect
retransmits is clearly wrong.

Really, dont recommend this paper, it contains a lot of false
statements.

One example : "we discovered some surprising things as the high
percentage of lost or reordered packets from supposedly highly reliable
and fast services as Akamai networks". 

I cant believe such nonsense can be written, and recommended.

So you can add more counters to TCP stack because having them is good to
better understand TCP behavior and what can be done to improve it, but
dont base this work on dubious 'tcphealth'.

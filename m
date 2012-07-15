From: "Piotr Sawuk" <a9702387@unet.univie.ac.at>
Subject: Re: resurrecting tcphealth
Date: Mon, 16 Jul 2012 00:17:51 +0200
Message-ID: <5d2836fd8198ee5d4c0f586238902cbb.squirrel@webmail.univie.ac.at>
References: <dee325378a2d3b7792da9640fc14905f.squirrel@webmail.univie.ac.at>
    <20120714144800.7f8c97f6@nehalam.linuxnetplumber.net>
    <b93cddfd0a19158ec59823140d1e2075.squirrel@webmail.univie.ac.at>
    <1342336597.3265.10617.camel@edumazet-glaptop>
    <3e426bd471b8a54bfa5320f05e88e635.squirrel@webmail.univie.ac.at>
    <1342346010.3265.10966.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from grace.univie.ac.at ([131.130.3.115]:53287 "EHLO
	grace.univie.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003Ab2GOWRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 18:17:53 -0400
In-Reply-To: <1342346010.3265.10966.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On So, 15.07.2012, 11:53, Eric Dumazet wrote:
> On Sun, 2012-07-15 at 11:17 +0200, Piotr Sawuk wrote:
>> On So, 15.07.2012, 09:16, Eric Dumazet wrote:
>> > On Sun, 2012-07-15 at 01:43 +0200, Piotr Sawuk wrote:
>> >
>> >> oh, and again I recommend the really short although outdated thesis
>> >>
>> >> [1] https://sacerdoti.org/tcphealth/tcphealth-paper.pdf
>> >
>> > A thesis saying SACK are not useful is highly suspect.
>> >
>> > Instead of finding why they behave not so good and fix the bugs, just
>> > say "SACK addition to TCP is not critical"
>> the actual quotation is "We also found that the number of unnecessary
>> duplicate packets were quite small potentially indicating that the SACK
>> addition to TCP is not critical."
>> >
>> > Really ?
>>
>> no, not really. he he actually said that SACK has been made mostly
>> obsolete
>> by "Linux 2.2 implements fast retransmits for up to two packet gaps, thus
>> reducing the need for course grained timeouts due to the lack of SACK."
>> and
>> he was a bit more careful and admitted that further tests with tcphealth
>> are
>> needed to check if SACK really makes that big a difference. he admitted
>> "It
>> could be that SACK's advantage lies in other areas such as very large
>> downloads or when using slow and unreliable network links." all these
>> things
>> could be checked again nowadays, with larger files available and
>> wlan-users
>> and higher traffic -- just find something without SACK...
>
> There are hundred of papers about TCP behavior. Many are very good.
>
> This one seems not the best of them by far, and is based on measures
> done on 2001 (!!!), on a single computer (!!!), connected to a
> particular ISP (!!!), using a wireless pcmcia network card. (!!!)
>
> At that time, almost no clients were using SACK. Because windows 98/XP
> dont negociate SACK by default (you need to tweak registry)
>
> Its like saying ECN is useless : If ECN users are under 1 % of total
> number of users, network is still under pressure and ECN benefits cannot
> rise because of misbehavior of other flows.

I don't think it's in any way similar, but then you definitely are more
knowledgeable on these matters. but it's quite straight-forward: SACK is
supposed to speed up things by informing when a packet has been received and
doesn't need to be resent. if the client doesn't get duplicate packets then
SACK wont make a difference. tcphealth counts how many packets have been
received correctly two or more times. why would tcphealth be useless for
answering if you'll need SACK?
>
> With RTT of 100 ms, SACK are clearly a win for long transferts.
>
> A single drop shall retransmit a single packet instead of ~500 packets.
> Only fools could deny this fact. Studying DuplicateAcks to detect
> retransmits is clearly wrong.

as far as I understood DuplicateAcks means either the Acks were lost in the
transfer or the same packet has been received twice one after the other.
i.e. duplicate packets received should always be smaller-or-equal than
duplicate acks sent. am I wrong? that's why tcphealth is only interested in
these two values.
>
> Really, dont recommend this paper, it contains a lot of false
> statements.
>
> One example : "we discovered some surprising things as the high
> percentage of lost or reordered packets from supposedly highly reliable
> and fast services as Akamai networks".
>
> I cant believe such nonsense can be written, and recommended.

I agree, it's quite some mickey-mouse thesis. but still a manual for what
tcphealth actually does do!
>
> So you can add more counters to TCP stack because having them is good to
> better understand TCP behavior and what can be done to improve it, but
> dont base this work on dubious 'tcphealth'.

what counters are you thinking of? how do you suggest an ordinary user could
improve the download-speed from sites? imho tcphealth offers a good method:
the more DuplicateAcks you send the less responsive the site is you want to
reach, so try at another time and do some other downloads now...

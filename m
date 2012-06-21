From: =?UTF-8?B?5p2O5piT?= <lovelylich@gmail.com>
Subject: Re: [RFC] tcp: How does SACK or FACK determine the time to start
 fast retransmition?
Date: Thu, 21 Jun 2012 18:17:36 +0800
Message-ID: <4FE2F4C0.4020900@gmail.com>
References: <CAAA3+BpRQ24HED6a+yCF+A_q=vJ7nHexLJd1U+-50pb43MVa5w@mail.gmail.com> <4FE2C03C.6030102@gmail.com> <CAGK4HS_CN53EtQvPm2H7Qn85eXRz7hiEQvs3bU3xXpcNeg4byg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, kernelnewbies@kernelnewbies.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:50701 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942Ab2FUKRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 06:17:53 -0400
Received: by dady13 with SMTP id y13so674584dad.19
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 03:17:53 -0700 (PDT)
In-Reply-To: <CAGK4HS_CN53EtQvPm2H7Qn85eXRz7hiEQvs3bU3xXpcNeg4byg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012/6/21 16:42, Vijay Subramanian =E5=86=99=E9=81=93:
> With SACK, number of  dupacks does not have much meaning. What matter=
s is
> --how the SACK scoreboard looks like i.e. which packets are tagged
> Lost/Sacked/Retransmitted
> -- Whether FACK is in use (this assumes holes in between sacked
> packets are lost and have left the network and so we can send out mor=
e
> packets)
>
> So, stack does not count the number of dupacks that have come in. Onl=
y
> SACK blocks matter.
> You can try to track the following path:
> tcp_ack() deals with incoming acks and if it sees a dupack (does not
> matter what number), or incoming packet contains SACK it calls
> tcp_fastretrans_alert() which calls  tcp_xmit_retransmit_queue().
>
> tcp_xmit_retransmit_queue() decides which packets to retransmit. The
> first packet to start retransmitting from is tracked in
> tp->retransmit_skb_hint.
> Note that the dupThresh is actually tracked by tp->reordering which
> measures  the reordering in the network and is not fixed at 3.  So, i=
f
> more than
> tp->reordering packets have been acked above a given packet, this
> packet is a candidate for retransmisson. See tcp_mark_head_lost() to
> see how the
> reordering metric is used to mark packets as lost. This corresponds t=
o
> the check you mentioned in the RFC.
>
> So, window permitting, packets are sent as follows;
> (a)-- Packets marked lost as per description above
> (b)-- new packets (if any)
> (c)-- Holes between sacked packets  which are not reliably lost.
>
> choice between (b) and (c) is made in tcp_can_forward_retransmit().
>
> Hope this helps.
> Vijay
>
It is just I wanted! Thanks for your detailed explaination and kindness=
=2E

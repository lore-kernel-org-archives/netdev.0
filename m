From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next v2] tcp: use RFC6298 compliant TCP RTO
 calculation
Date: Thu, 16 Jun 2016 11:03:58 +0200 (CEST)
Message-ID: <1688164699.25825.1466067838281@office.mailbox.org>
References: <CAK6E8=dWLF+gRprxEbHRLnkRNHmf5sbedtv2Dt1jOqKPh7fmjA@mail.gmail.com>
 <20160614191841.21496-1-dmetz@mytum.de>
 <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
 <20160615174114.GA16217@virgo.localdomain>
 <CAK6E8=fgQitOiXwjjn0gq93w7m5DQ2OHr_wvq-oGeAF2fhE-uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Metz <dmetz@mytum.de>, netdev <netdev@vger.kernel.org>,
	Daniel Metz <daniel.metz@rohde-schwarz.com>,
	Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mailbox.org ([80.241.60.215]:45698 "EHLO mx2.mailbox.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbcFPJEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 05:04:08 -0400
In-Reply-To: <CAK6E8=fgQitOiXwjjn0gq93w7m5DQ2OHr_wvq-oGeAF2fhE-uA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On June 15, 2016 at 8:02 PM Yuchung Cheng <ycheng@google.com> wrote:
> 
> Let's say the SRTT is 100ms and RTT variations is 10ms. The variation
> is low because we've been sending large chunks, and RTT is fairly
> stable, and we sample on every ACK. The RTOs produced are
> 
> RFC6298: RTO=1s
> Linux: RTO=300ms
> This patch: RTO=200ms
> 
> Then we send 1 packet out. The receiver delays the ACK up to 200ms.
> The actual RTT can be longer because other network components further
> delay the data or the ACK. This patch would surely fire the RTO
> spuriously.
> 
> so we can either implement RFC6298 faithfully, or apply the
> lower-bound as-is, or something in between. But the current patch
> as-is is more aggressive. Did I miss something?

We analyzed the impact for a wide variety of network characteristics. Starting from bulk data till chatty, sender-limited transmissions from low RTTs to high RTTs, small and large variances as well as different queue characteristics. For a group of tests we measured advantages of a RFC 6298 compliant implementation: sender-limited flows. For bulk data we did not measured any difference compared to standard Linux. As a result we concluded that the RFC conform implementation - mapped to real world protocols - if beneficial.

For the mentioned use case, yes the new implementation is a little bit more aggressive: when delayed ack kicks in, a spurious retransmission can be triggerd, yes. We asked ourself if this is a real world scenario or more an theoretical issue. Furthermore, if a real world problem, if the retransmission is negligible compared to the advantages?

Yuchung, can you test the patch and see if the patch have any downsides? And thank you for the comments!

Hagen

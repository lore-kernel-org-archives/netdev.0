From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: empty ack packets
Date: Fri, 10 Sep 2010 09:06:24 +0200
Message-ID: <4bb006381ebf718d3c7bcb002d1ea924@localhost>
References: <AANLkTimkvDsqY==1JQRhH54+P7yAzFX4omYN0r9+_mi=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: MK <stardust496@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:36941 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751258Ab0IJG4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 02:56:46 -0400
In-Reply-To: <AANLkTimkvDsqY==1JQRhH54+P7yAzFX4omYN0r9+_mi=@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 10 Sep 2010 01:12:44 -0400, MK wrote:

> Hello list,

> 

> I am looking at a tcpdump and I see that very very frequently, after

> receiving a segment, my tcp is sending an empty ack back in a matter

> of several (around 20 - 50) microseconds. And then after several more

> microseconds, my tcp is sending some valid outgoing data. I am trying

> to understand why it decided to send an empty ack back when that ack

> could potentially have been delayed by microseconds and get

> piggybacked on the outgoing data.

> 

> From the code, it appears that the delayed ack timeout is 40 millisecs

> so it is likely not the delack timer that is causing this. (And I do

> not have the quickack option)

> 

> This is RHEL5 (2.6.18) kernel.

> 

> Does anybody have an idea as to what is happening?



The mechanism behind is called TCP Quick ACK and was introduced to raise

the Congestion Window more quickly for non-interactive streams. If the

stack detects that the stream is interactive (can piggy-back data) the

quick ACK is disabled. But the heuristic demand at least one packet to

detect that the flow is interactive. Currently the mechanism favor

non-interactive flows and generate at least on "unnecessary" ACK packet.

The alternative approach is to always delay the first ACK and after that

decide if a stream is interactive or not. But this will penalize bulk data

transfer, because the CW is raised slower and additionally, the first

return packet may not be triggered instantly. 



See the following discussion and patch where the mechanism is made

modifiable (I will drop a new patch but this take some time (vacation)):



http://kerneltrap.org/mailarchive/linux-netdev/2010/8/23/6283640



Hagen

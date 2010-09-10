From: MK <stardust496@gmail.com>
Subject: Re: empty ack packets
Date: Fri, 10 Sep 2010 06:57:18 -0400
Message-ID: <AANLkTinJCXaWPGmd0HXDaN8fT=nY8jeoY7Hb0Aw-TAod@mail.gmail.com>
References: <AANLkTimkvDsqY==1JQRhH54+P7yAzFX4omYN0r9+_mi=@mail.gmail.com>
	<4bb006381ebf718d3c7bcb002d1ea924@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:37515 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785Ab0IJK5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 06:57:19 -0400
Received: by vws3 with SMTP id 3so2356614vws.19
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 03:57:19 -0700 (PDT)
In-Reply-To: <4bb006381ebf718d3c7bcb002d1ea924@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen,

My flow is most certainly in both directions. ( I am guessing that
means pingpong will be true and so no quickack by default unless I
explicitly enable it which I am not.)

Thanks....

On Friday, September 10, 2010, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
>
> On Fri, 10 Sep 2010 01:12:44 -0400, MK wrote:
>> Hello list,
>>
>> I am looking at a tcpdump and I see that very very frequently, after
>> receiving a segment, my tcp is sending an empty ack back in a matter
>> of several (around 20 - 50) microseconds. And then after several more
>> microseconds, my tcp is sending some valid outgoing data. I am trying
>> to understand why it decided to send an empty ack back when that ack
>> could potentially have been delayed by microseconds and get
>> piggybacked on the outgoing data.
>>
>> From the code, it appears that the delayed ack timeout is 40 millisecs
>> so it is likely not the delack timer that is causing this. (And I do
>> not have the quickack option)
>>
>> This is RHEL5 (2.6.18) kernel.
>>
>> Does anybody have an idea as to what is happening?
>
> The mechanism behind is called TCP Quick ACK and was introduced to raise
> the Congestion Window more quickly for non-interactive streams. If the
> stack detects that the stream is interactive (can piggy-back data) the
> quick ACK is disabled. But the heuristic demand at least one packet to
> detect that the flow is interactive. Currently the mechanism favor
> non-interactive flows and generate at least on "unnecessary" ACK packet.
> The alternative approach is to always delay the first ACK and after that
> decide if a stream is interactive or not. But this will penalize bulk data
> transfer, because the CW is raised slower and additionally, the first
> return packet may not be triggered instantly.
>
> See the following discussion and patch where the mechanism is made
> modifiable (I will drop a new patch but this take some time (vacation)):
>
> http://kerneltrap.org/mailarchive/linux-netdev/2010/8/23/6283640
>
> Hagen
>

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Inconsistency in ipv4/tcp_input regarding sequence number
 acceptability condition
Date: Mon, 22 May 2017 10:00:01 -0700
Message-ID: <1495472401.6465.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <f209ec7a-7d14-0112-e906-69c016298aa5@science.ru.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul Fiterau Brostean <p.fiterau-brostean@science.ru.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34858 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759243AbdEVRAD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 13:00:03 -0400
Received: by mail-pf0-f182.google.com with SMTP id n23so87883945pfb.2
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 10:00:03 -0700 (PDT)
In-Reply-To: <f209ec7a-7d14-0112-e906-69c016298aa5@science.ru.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-22 at 17:24 +0200, Paul Fiterau Brostean wrote:
> Hello esteemed Linux Developers,
> 
> My name is Paul, I am a PhD student. I sent a different question a while 
> back to the netdev mailing list, and never got a response. This question 
> should be a lot easier to address. While doing experiments on the Linux 
> TCP stack as part of a research project, I have stumbled upon a 
> potential inconsistency with the RFC specification.
> 
> The Linux TCP stack considers a received sequence number as in-window or 
> acceptable, if the sequence number of the segment is between the 
> expected sequence number and the expected sequence number plus the size 
> of the receive window. Naturally, the lower bound is included in the 
> range. What's a bit weird is that the upper bound of this range is also 
> considered in-window. This is evident both from my experiments and from 
> the code 
> (http://elixir.free-electrons.com/linux/v4.11/source/net/ipv4/tcp_input.c#L3985).
> 
> The RFC states that the upper bound shouldn't be considered. If we look 
> at: https://tools.ietf.org/html/rfc793#page-26  the acceptability 
> conditions exclude  RCV.NXT+RCV.WND (where applicable). Is there a 
> reason for Linux including the upper bound? Or can this be fixed?
> 
> Analyzing FreeBSD, they seem to have adopted the RFC standard, and have 
> not included the upper bound.
> 
> 
> As an aside, my work involves automatic inference of models from 
> software components. We obtained models for FreeBSD and Linux TCP 
> clients and comparing them we were able to spot this minor difference. 
> The models we can obtain automatically abstract away from many 
> complexities (like timing, re-transmissions), and only consider socket 
> calls and flags/seq/ack numbers (payloads are 0). I attached a Linux 
> model to give you an example. If you look at the ESTABLISHED state, 
> receiving a RST  segment (R), prompts the Linux system to respond with a 
> challenge ACK segment (A) if the sequence number (p1) satisfies the 
> condition: 'r1+win >=p1 && r1<p1' where 'r1' is the expected sequence 
> number and 'win' is the receive window size.
> 
> Thanks for your attention, Paul.


Hi Paul

I am planning to send a fix for this.

( Internal Google Bug Id : 37204158,  filled April 10th )

I did replied to you, but I got other more urgent work to do.

Thanks.

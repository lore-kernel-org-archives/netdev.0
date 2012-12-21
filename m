From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 11:27:32 -0800
Message-ID: <1356118052.21834.7793.camel@edumazet-glaptop>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
	 <1356114663.21834.7697.camel@edumazet-glaptop>
	 <CALvgte9x4LWV8rsquKzNoVcXM14xZjvyuTgpHr-ynZXfGtzzpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhiyun Qian <zhiyunq@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:44305 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab2LUT1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 14:27:34 -0500
Received: by mail-pb0-f44.google.com with SMTP id uo1so2923570pbc.17
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 11:27:34 -0800 (PST)
In-Reply-To: <CALvgte9x4LWV8rsquKzNoVcXM14xZjvyuTgpHr-ynZXfGtzzpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 14:10 -0500, Zhiyun Qian wrote:
> That's good to know. However, implementing RFC 5961 alone is not
> sufficient. Like I said, since DelayedAckLost counter is incremented
> purely upon looking at the sequence number, regardless of the ACK
> number. An attacker thus can still infer the sequence number based on
> DelayedAckLost counter without knowing the right ACK number.
> 



> The next question is how can the attacker eventually know the right
> ACK number in order to inject real data. It turns out that this is not
> hard either. First, based on the current Linux TCP stack, it accepts
> incoming packets without ACK flag. 

I dont really think so.

We must discard frame is th->ack is not set. (Step 5, line 6142)



> Further, if ACK flag is not set,
> ACK number will not be checked at all. See code in
> net/ipv4/tcp_input.c, function tcp_rcv_established()
> 
> 5547        if (th->ack && tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
> 5548                goto discard;
> 
> Second, even if ACK number is always checked before accepting the
> payload, it is still possible to infer the ACK number much like how
> sequence number can be inferred. The details is described in Section
> 3.4 of my paper, paragraph starting with "Client-side sequence number
> inference".
> 
> I'm looking at the latest kernel v3.7.1 right now. I believe the
> problem do still exist in today's Linux.
> 

It seems you know pretty well this code, I wonder why you dont send
patches to fix the bugs...

Its not like it has to be buggy forever.

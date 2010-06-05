From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] act_cpu: redirect skb receiving to a special CPU.
Date: Sat, 05 Jun 2010 09:54:05 -0400
Message-ID: <1275746045.3490.60.camel@bigi>
References: <AANLkTikskTWJrULj2IKYhebxh9O_XTOMBy3i0wPY8thq@mail.gmail.com>
	 <1275743224.3490.44.camel@bigi>
	 <AANLkTiltF2APEnqHyHTtHA7JMNp3HX3aCu9UL3nUJ5_u@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:40445 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754707Ab0FENyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 09:54:08 -0400
Received: by vws5 with SMTP id 5so1040259vws.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 06:54:07 -0700 (PDT)
In-Reply-To: <AANLkTiltF2APEnqHyHTtHA7JMNp3HX3aCu9UL3nUJ5_u@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-06-05 at 21:26 +0800, Changli Gao wrote:

> ingress doesn't have any qdisc, but a class tree. The ingress_queue
> will be sth. like this:
[..]

> Then we can classify skbs in tree  manner.
[..]
> > The cpuid should be sufficient to map to a remote cpu queue, no?
> 
> It should be sufficient, but it isn't efficient. With map option, we
> can use cls_flow to map traffic to classid, and use act_cpu map to map
> classid to cpuid.

I am missing something, I would see the flow as:
-->ethx/lo/etc->ingressqdisc->classify-->action(redirect to cpuidX)
Why/when do you need the tree variant? If you are thinking of maybe
rate limiting to a specific CPU, then would passing it to a policer
first not be sufficient?  IOW, classid is not very useful.

> I won't implement a new netdevice, but reuse the softnet. Even, I'll
> reuse the enqueue_to_backlog() introduced by RPS, and of course, use
> IPIs as RPS. Is there another way to trigger an IRQ of the remote CPU?

I would look at it as "messaging of remote CPU" which may not result
in an IRQ. I am pretty sure if you tried hard you could use HT in AMD
hardware - the remote cpu may have an IRQ triggered but it wont be as
expensive as IPI.

cheers,
jamal


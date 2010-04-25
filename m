From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Sun, 25 Apr 2010 10:31:33 +0800
Message-ID: <t2r412e6f7f1004241931ie9e70e3aka77b49557a7872e3@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271489739.16881.4586.camel@edumazet-laptop> <1271525519.3929.3.camel@bigi>
	<1271583573.16881.4798.camel@edumazet-laptop> <1271590476.16881.4925.camel@edumazet-laptop>
	<1271764941.3735.94.camel@bigi> <1271769195.7895.4.camel@edumazet-laptop>
	<1271853570.4032.21.camel@bigi> <1271876480.7895.3106.camel@edumazet-laptop>
	<1271938343.4032.30.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:55467 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940Ab0DYCby convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 22:31:54 -0400
Received: by iwn8 with SMTP id 8so3926212iwn.16
        for <netdev@vger.kernel.org>; Sat, 24 Apr 2010 19:31:53 -0700 (PDT)
In-Reply-To: <1271938343.4032.30.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 8:12 PM, jamal <hadi@cyberus.ca> wrote:
>
>> I see slave/application cpus hit _raw_spin_lock_irqsave() and
>> _raw_spin_unlock_irqrestore().
>>
>> Maybe a ring buffer could help (instead of a double linked queue) fo=
r
>> backlog, or the double queue trick, if Changli wants to respin his
>> patch.
>>
>
> Ok, I will have some cycles later today/tommorow or for sure on weeke=
nd.
> My setup is still intact - so i can test.
>

I read the code again, and find that we don't use spin_lock_irqsave(),
and we use local_irq_save() and spin_lock() instead, so
_raw_spin_lock_irqsave() and _raw_spin_lock_irqrestore() should not be
related to backlog. the lock maybe sk_receive_queue.lock.

Jamal, did you use a single socket to serve all the clients?

BTW:  completion_queue and output_queue in softnet_data both are LIFO
queues. For completion_queue, FIFO is better, as the last used skb is
more likely in cache, and should be used first. Since slab has always
cache the last used memory at the head, we'd better free the skb in
=46IFO manner. For output_queue, FIFO is good for fairness among qdiscs=
=2E

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

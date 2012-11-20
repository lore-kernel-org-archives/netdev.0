From: Javier Domingo <javierdo1@gmail.com>
Subject: Fwd: Network soft and hard irqs statistics
Date: Tue, 20 Nov 2012 16:05:36 +0100
Message-ID: <CALZVapky_zgCOQzafyi6iAyxf4LobiqEDP6Sw3uVQvD9+fBUDQ@mail.gmail.com>
References: <CALZVapnXkUvdst0sC5sWCFkiLEGq5RXg6=0Lyt+nT-SheaxiSg@mail.gmail.com>
 <CALZVapkHda-tYNJALJWjhGwFBjAet84gxJam2UoK9WzMKQE6Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:62083 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437Ab2KTPF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 10:05:57 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so603466vbb.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 07:05:57 -0800 (PST)
In-Reply-To: <CALZVapkHda-tYNJALJWjhGwFBjAet84gxJam2UoK9WzMKQE6Bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have released the mentioned code in

https://github.com/txomon/linux

It now is giving some kernel panics due to some page fault during
net_rx_action because I didn't know how to put this in current kernel,
but I am currently working in an alternative solution

https://github.com/txomon/linux/blob/affde7645451eb62cdd1993a8cef7b5325e30b96/net/core/dev.c#L3944

Hope someone can help me now :D

Javier Domingo



2012/11/15 Javier Domingo <javierdo1@gmail.com>
>
> Hello all,
>
> I am migrating some statistics we use in our research group to v3.6.
> This I don't think it will be usefull for anyone, as they measure
> softirqs, hardirqs, times on them, etc.
>
> We modified net_device structure to contain a structure that has
> several field of statistics.
>
> Patched the e1000 and tg3 drivers to measure hardirq times, and
> polling times. We also patched net_rx_action (the softirq) to check if
> we get out per budget, per jiffies and netif_receive_skb to measure
> times and how many packets are captured.
>
> At the moment, we have been working with a external module that
> accessed this vars, creating proc entries, and allowing us to reset
> those measures.
>
> Now, I am trying to make it the most standard way, with the intention
> that when I talk to my boss, he will allow me to release the code.
>
> The main aim of this is to get some feedback about the interest this
> can have and to ask a few questions:
>
> -> Where may I create the proc entry? we currently use
> /proc/net/stats/<netdev>. I have also thought introducing that entry
> in fs/proc/proc_net.c, but I am not too sure which conventions there
> are...
>
> -> When migrating the net_rx_action, I found that we used this line:
> if(cpus_equal(mask,irq_desc[timedev->irq].affinity))
> before counting if we get out by budget or by jiffies to (I suppose)
> check that the softirq was the one assigned to this processor. Is that
> needed? I mean the softirq is run in just one of them... I don't
> really understand why it is important, so if anyone can explain me, I
> would be glad.
>
> -> We have patched the hardirqs in the driver, and the polling times
> too. I know the hardirqs are the only place in which we can measure
> them, but would it be posible to, instead of measuring the polls in
> e1000_clean (for example) measuring in dev.c net_rx_action, measure
> them around n->poll() call?
>    Have been doing like this because they told me that the context
> change was important... But I am not too sure on how important it is,
> if someone could give me any tip on this.
>
> -> In tg3.c I have seen that there are several hardirq function,
> though we usually only patched tg3_interrupt_tagged, I have patched
> all of them (for what they might be). Why are so many of them? Is that
> due to preparation for multiqueue cards?
>
> I hope someone can attend my doubts, and that I dont have asked too
> many newbie questions.
>
> Best regards,
>
> Javier Domingo

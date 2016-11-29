From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 4.9-rc7: (forcedeth?) BUG: sleeping function called from
 invalid context at kernel/irq/manage.c:110
Date: Tue, 29 Nov 2016 15:00:43 -0800
Message-ID: <1480460443.18162.157.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LRH.2.20.1611292222200.31348@math.ut.ee>
         <CAADWXX8GM5Xdf1Of09ABXEB8eb=eVqPjHTaT7ZzcStnX8=cO_A@mail.gmail.com>
         <alpine.LRH.2.20.1611292309490.31348@math.ut.ee>
         <1480449495.18162.152.camel@edumazet-glaptop3.roam.corp.google.com>
         <CA+55aFwUFPLbcqpoccKXHsGj_80ANaMwCSgwTUqgxMFmNRHkaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Meelis Roos <mroos@linux.ee>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33414 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750754AbcK2XAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 18:00:46 -0500
In-Reply-To: <CA+55aFwUFPLbcqpoccKXHsGj_80ANaMwCSgwTUqgxMFmNRHkaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-29 at 12:06 -0800, Linus Torvalds wrote:
> On Nov 29, 2016 11:58 AM, "Eric Dumazet" <eric.dumazet@gmail.com>
> wrote:
> >
> > nv_do_nic_poll() is simply buggy and needs a fix.
> >
> > synchronize_irq() can sleep.
> 
> Yes, but why did it start showing up now? None of this has changed as
> far as I can see?
> 
> Is it just timing and the transmit queue being busy? Perhaps due to
> the sheer size of messages? Meelis does seem to have a ton of
> debugging enabled..
> 
>     Linus
> 
> 
Looks like bad luck really or forced_irqthreads ? 


These commits contain what is wanted.

02cea3958664723a5d2236f0f0058de97c7e4693 
genirq: Provide disable_hardirq()



18258f7239a61d8929b8e0c7b6d46c446459074c
genirq: Provide synchronize_hardirq()

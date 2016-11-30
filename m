From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Aw: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Wed, 30 Nov 2016 07:47:18 -0800
Message-ID: <1480520838.18162.180.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DB0228849@AcuExch.aculab.com>
         <1480090590.8455.549.camel@edumazet-glaptop3.roam.corp.google.com>
         <trinity-a100658c-7fd5-47b3-ab3f-1f0a80774ccc-1480091457793@3capp-gmx-bs57>
         <1480101551.8455.557.camel@edumazet-glaptop3.roam.corp.google.com>
         <b58286a4-d97f-18dd-e5bd-0f69d3746b81@gmx.de>
         <1480378759.18162.105.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DB0230455@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33868 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbcK3PsU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:48:20 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so1666959pgc.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 07:48:20 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0230455@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 15:28 +0000, David Laight wrote:

> Are you sure??

Yes I am

> Last I looked gcc seemed to convert 'foo++' to 'foo = foo + 1' before
> generating any code.

Your gcc might need a refresh then.

> It might then optimise that back to a memory increment, but that would
> also happen if you'd coded the latter form.
> 
> > Which is kind of unfortunate, given it is the fast path.
> > 
> > Better add a comment, like :
> > 
> > /* We should use WRITE_ONCE() to pair with the READ_ONCE() found in xxxx()
> >  * But gcc would generate non optimal code.
> >  */
> 
> Actually while READ_ONCE() is generally useful - to get a snapshot of a changing value.
> 
> WRITE_ONCE() isn't a pairing - the compiler is highly unlikely to write a
> location twice.

WOW. I can not believe what you just said.

We had numerous bugs because compiler was writing on the location
temporary computations. Just take a look at git history to find some
gems.

> You might want an annotation to ensure is doesn't assume it can read the value
> back (write through volatile pointer). But that has nothing to do with how readers behave.

Completely wrong.

From: "Alexey Dobriyan" <adobriyan@gmail.com>
Subject: Re: pktgen
Date: Thu, 30 Nov 2006 10:30:45 +0300
Message-ID: <b6fcc0a0611292330n42fb1485h59804cc94a332f19@mail.gmail.com>
References: <20061121212251.GA5084@martell.zuzino.mipt.ru>
	 <20061128.153325.10304536.davem@davemloft.net>
	 <20061129200437.GA5152@martell.zuzino.mipt.ru>
	 <20061129.174943.112291690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pavol.gono@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:29189 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758543AbWK3Has (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 02:30:48 -0500
Received: by nf-out-0910.google.com with SMTP id o25so3160419nfa
        for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 23:30:46 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061129.174943.112291690.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/30/06, David Miller <davem@davemloft.net> wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Wed, 29 Nov 2006 23:04:37 +0300
>
> > Looks like worker thread strategically clears it if scheduled at wrong
> > moment.
> >
> > --- a/net/core/pktgen.c
> > +++ b/net/core/pktgen.c
> > @@ -3292,7 +3292,6 @@ static void pktgen_thread_worker(struct
> >
> >  	init_waitqueue_head(&t->queue);
> >
> > -	t->control &= ~(T_TERMINATE);
> >  	t->control &= ~(T_RUN);
> >  	t->control &= ~(T_STOP);
> >  	t->control &= ~(T_REMDEVALL);
>
> Good catch Alexey.  Did you rerun the load/unload test with
> this fix applied?  If it fixes things, I'll merge it.

Well, yes, it fixes things, except Ctrl+C getting you out of
modprobe/rmmod loop will spit
backtrace again. And other flags: T_RUN, T_STOP. Clearance is not
needed due to kZalloc and
create bugs as demostrated.

Give me some time.

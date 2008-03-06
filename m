From: jamal <hadi@cyberus.ca>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 06 Mar 2008 18:40:39 -0500
Message-ID: <1204846839.4431.23.camel@localhost>
References: <20080224222035.M62480@visp.net.lb>
	 <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb>
	 <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb>
	 <20080306134015.GA4571@ff.dom.local> <1204811995.4440.30.camel@localhost>
	 <20080306175629.GA2876@ami.dom.local> <1204836523.4457.103.camel@localhost>
	 <20080306214000.GC2876@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:43961 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757448AbYCFXkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:40:42 -0500
Received: by py-out-1112.google.com with SMTP id u52so237766pyb.10
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 15:40:41 -0800 (PST)
In-Reply-To: <20080306214000.GC2876@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek,

On Thu, 2008-06-03 at 22:40 +0100, Jarek Poplawski wrote:

> But currently lockdep doesn't know dev->queue_lock could mean eth or lo.
> It sees one class of devices using one lock. 

yikes ;-> I missed the implication when you mentioned it first - thanks
for the enlightnment. IMO, it needs to be per netdevice not global; so i
contend this is the problem i.e those warnings are false.

> We can let it know (e.g.
> dev->_xmit_lock is different according to dev->type), but it wasn't
> necessary. I hope it will suffice here if lockdep knows more about ifb,
> but similar problem could theoretically happen with other devs.

I think the condition needs to be met for all netdevices, not just ifb.
Instead of annotating each netdevice type separately, could you not use
a different annotation in the generic netdev registration code of the
form dev_%s->ingress/queue_lock ? (where %s is dev->name)

> Sorry, should be:
>  dev_eth0->queue_lock, and thread3 has dev_eth0->queue_lock and wants

indeed - i understood when you said that; it doesnt invalidate what i
said.

> > thread3 can not happen because we dont allow it (the other 2 are not
> > contentious).
> 
> Could you explain why? 

Because we never redirect to ingress (it is in the todo as mentioned as
described at the top of the source file). You can redirect from ingress
or egress but only to egress (to sockets and ingress are going to happen
at some future point).

> Yes, but it seems such redirection between two eths like above mentioned
> is legal?

Indeed it is. I think it is clear to me now the issues seem to be the
namespace of what lockdep - it should be per-device and NOT global.
What do you think?

cheers,
jamal


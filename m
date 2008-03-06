From: jamal <hadi@cyberus.ca>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 06 Mar 2008 15:44:48 -0500
Message-ID: <1204836288.4457.100.camel@localhost>
References: <20080224222035.M62480@visp.net.lb>
	 <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb>
	 <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb>
	 <20080306134015.GA4571@ff.dom.local>  <20080306135625.M25627@visp.net.lb>
	 <1204813634.4440.59.camel@localhost>  <20080306143910.M91001@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:54117 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755769AbYCFUoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 15:44:55 -0500
Received: by wx-out-0506.google.com with SMTP id h31so74805wxd.4
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 12:44:52 -0800 (PST)
In-Reply-To: <20080306143910.M91001@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-06-03 at 17:50 +0200, Denys Fedoryshchenko wrote:

> Well, i am able to reproduce in much more trivial script. Tested 2.6.25-rc4 
> also.
> 
> modprobe ifb
> ifconfig ifb0 up
> TC=/sbin/tc
> $TC qdisc del dev eth0 ingress 1>/dev/null 2>/dev/null
> $TC qdisc add dev eth0 ingress
> ${TC} filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
>       match u32 0 0 flowid 1:1 \
>       action mirred egress redirect dev ifb0
> 

I have tried this on my laptop - 2.6.24 and it doesnt happen. Indicates
whatever issues that are occuring must be post 2.6.24 since you are
running something newer. 


> > locks(ethx, ifbx, and loopback). Smells like lockdep is getting it wrong?
> No idea, i have strange lockup's on my systems where i have ifb, and that 
> make me worry. And i feel it is directly related with my love to use ifb 
> devices and way how i am using them.

I will like to help resolve it - if i can reproduce it i can fix it. I
love the fact you love to use ifb. I am going to try later on 2.6.25-rc4
that you are running.

> > This sounds like a different issue from above - when did this start 
> > to happen? Is it at the same time as above warnings showing up?
> 
> Yes, it is different issue seems, it is rare to lockup system , and i will 
> dig more, to understand how it is happening.

Are you running std kernels or do you have some other patches?

cheers,
jamal


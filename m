From: jamal <hadi@cyberus.ca>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 06 Mar 2008 15:48:42 -0500
Message-ID: <1204836523.4457.103.camel@localhost>
References: <20080224222035.M62480@visp.net.lb>
	 <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb>
	 <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb>
	 <20080306134015.GA4571@ff.dom.local> <1204811995.4440.30.camel@localhost>
	 <20080306175629.GA2876@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:59009 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759791AbYCFUsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 15:48:47 -0500
Received: by wx-out-0506.google.com with SMTP id h31so77068wxd.4
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 12:48:46 -0800 (PST)
In-Reply-To: <20080306175629.GA2876@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-06-03 at 18:56 +0100, Jarek Poplawski wrote:

> Every netdevice after register_netdevice() has its queue_lock and
> ingress_lock initialized with the same static lock_class_keys, so unless
> changed later, these locks are treated by lockdep as 2 global locks.
>  So, taking such locks with different order should be reported. 

ok.

> This really
> happens in act_mirred, and I don't know yet, why this wasn't reported
> earlier.

Look closely at those traces again ;-> there are *three* different
netdevices involved, one (loopback) seems to be _totaly_ unrelated.
Tracing of those locks just seems confused - perhaps the pernet stuff is
confusing loopback?

> Of course, if there are two different devices this could be safe, but
> not always (e.g. thread1 has dev_eth0->ingress_lock and wants
> dev_eth1->queue_lock, thread2 has dev_eth1->ingress_lock, wants
> dev_eth0->qdisc_lock, and thread3 has dev_eth0->qdisc_lock and wants
> dev_eth0->ingress_lock). With ifb this shouldn't be the case, but
> anyway we have to tell lockdep that ifb uses a different pair of locks.

thread3 can not happen because we dont allow it (the other 2 are not
contentious).
There are cases where redirecting will cause you problems (example if
you redirected to yourself and cause an infinite redirect) which are
listed in iproute2/doc. Denys script is fine afaics.






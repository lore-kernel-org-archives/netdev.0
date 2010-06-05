From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] act_cpu: redirect skb receiving to a special CPU.
Date: Sat, 05 Jun 2010 10:26:44 -0400
Message-ID: <1275748004.3490.86.camel@bigi>
References: <AANLkTikskTWJrULj2IKYhebxh9O_XTOMBy3i0wPY8thq@mail.gmail.com>
	 <1275743224.3490.44.camel@bigi>
	 <AANLkTiltF2APEnqHyHTtHA7JMNp3HX3aCu9UL3nUJ5_u@mail.gmail.com>
	 <1275746045.3490.60.camel@bigi>
	 <AANLkTim83nfQDuLNmYAvk6RBqxot0t6cGq-lbic4-DSs@mail.gmail.com>
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
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56919 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754846Ab0FEO0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 10:26:47 -0400
Received: by vws5 with SMTP id 5so1072270vws.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 07:26:46 -0700 (PDT)
In-Reply-To: <AANLkTim83nfQDuLNmYAvk6RBqxot0t6cGq-lbic4-DSs@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-06-05 at 22:15 +0800, Changli Gao wrote:

> For instance: there are 4 CPUs. I want redirect traffic to CPU 1-3
> evenly. If the qdisc is linear the rules as
> 
> flow classify(flow classid ffff:2-4) | tc_index 2 action cpu 1 |
> tc_index 3 action cpu 2 | tc_index 4 action cpu3
> 
> a tree variant:
> 
> class ffff:1 : flow classify(flow classid ffff:2-4)
> class ffff:2 parent ffff:1 : action cpu 1
> class ffff:3 parent ffff:1 : action cpu 2
> class ffff:4 parent ffff:1 : action cpu 3
> 
> ingress_classify: use flow classify to get the subclass ID, then find
> the corresponding class and exec action.
> 
> When there are lots of CPUs, tree is more efficient.

I still didnt follow .. 
Even if i had a million CPUs, A classifier matches some filter
and an action already bound to filter is executed. So the expensive
part is the classifier lookup.

> It seems AMD specific. Why do the AMD guys use this to implement async
> smp_call_function() if it is useful as you said?

Indeed it is AMD specific - but my view is if i was using AMD that would
be more efficient way of doing it; i.e IPI is the lowest common
denominator which works on all archs. Essentially what i am saying is
this would be a "inter-cpu messaging netdev" and i could replace its
send/recv parts from what we do in the RPS path right now to one that
uses AMD hypertransport etc.

cheers,
jamal


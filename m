From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 22 Apr 2010 08:12:23 -0400
Message-ID: <1271938343.4032.30.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
	 <1271764941.3735.94.camel@bigi> <1271769195.7895.4.camel@edumazet-laptop>
	 <1271853570.4032.21.camel@bigi>
	 <1271876480.7895.3106.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:49244 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695Ab0DVMM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 08:12:29 -0400
Received: by qyk9 with SMTP id 9so11103951qyk.1
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 05:12:28 -0700 (PDT)
In-Reply-To: <1271876480.7895.3106.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-21 at 21:01 +0200, Eric Dumazet wrote:

> Drawback of using a fixed src ip from your generator is that all flows
> share the same struct dst entry on SUT. This might explain some glitches
> you noticed (ip_route_input + ip_rcv at high level on slave/application
> cpus)

yes, that would explain it ;-> I could have flows going to each cpu
generating different unique dst. It is good i didnt ;->

> Also note your test is one way. If some data was replied we would see
> much use of the 'flows'
> 

In my next step i wanted to "route" these packets at app level and for
this stage of testing just wanted to sink the data to reduce experiment
variables. Reason:
The netdev structure would hit a lot of cache misses if i started using
it to both send/recv since lots of things are shared on tx/rx (example
napi tx prunning could happen on either tx or receive path); same thing
with qdisc path which is at netdev granularity.. I think there may be
room for interesting improvements in this area..

> I notice epoll_ctl() used a lot, are you re-arming epoll each time you
> receive a datagram ?

I am using default libevent on debian. It looks very old and maybe
buggy. I will try to upgrade first and if still see the same
investigate.
  
> I see slave/application cpus hit _raw_spin_lock_irqsave() and  
> _raw_spin_unlock_irqrestore().
> 
> Maybe a ring buffer could help (instead of a double linked queue) for
> backlog, or the double queue trick, if Changli wants to respin his
> patch.
> 

Ok, I will have some cycles later today/tommorow or for sure on weekend.
My setup is still intact - so i can test.

cheers,
jamal


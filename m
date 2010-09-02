From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Thu, 2 Sep 2010 19:17:05 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D067357@nsmail.netscout.com>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com><1283356463.2556.351.camel@edumazet-laptop><AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com><20100901.183251.106803238.davem@davemloft.net><20100901184802.5a79cf9f@nehalam><D3F292ADF945FB49B35E96C94C2061B90D0670D1@nsmail.netscout.com> <AANLkTimtF7jmoEm+ZexsC_rZGNq8zHxddj7pepomwO35@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <shemminger@vyatta.com>,
	"David Miller" <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: "Tom Herbert" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og101.obsmtp.com ([64.18.1.181]:45304 "HELO
	exprod6og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754056Ab0IBXRN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 19:17:13 -0400
Content-class: urn:content-classes:message
In-Reply-To: <AANLkTimtF7jmoEm+ZexsC_rZGNq8zHxddj7pepomwO35@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Tom Herbert [mailto:therbert@google.com]
> Sent: September 02, 2010 3:53 PM
> To: Loke, Chetan
> Cc: Stephen Hemminger; David Miller; eric.dumazet@gmail.com;
> netdev@vger.kernel.org
> Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
> 
> > userland folks who actually try to exploit the MQ/MSIX-ness will
> almost
> > always pin down their high-prio[or subset of] threads/processes.
> >
> I don't really see that.  Pinning is a last resort and in this context
> we could only do that on a dedicated server.  On a shared server, with
> many different apps, pinning for MQ/MSIX is not an easy option;
> meeting scheduler constraints will be the first priority and its up to
> networking to work with the scheduler to to the right thing.
> Scheduler aware networking (or vice versa) is important.
> 

For my use-case it's an appliance. Newer adapters might have like 64+(?)
h/w queues and not just f/w emulated queues. With these many queues you
could partition your threads/queues, no?
It's easier to get started that way. All you need is a shim(or just a
driver stub because you can then load it on any box that had older
kernels) in the kernel that will tell you which queue-set(for a
MQ-capable adapter) is still under the high-watermark. If all are full
then it should just round-robin(across queues and nodes).So make a
syscall(or shoot a mbx-cmd or pick your trick), find out which queue you
could use, get the binding info and then launch your threads. So once
you narrow down the scope, the scheduler will have less work to do.

If the worker threads are short lived then there's no point in this
binding. And for long-lived tasks, a couple of initial prep-calls will
not hurt performance that much.And if you still care about syscalls at
runtime then you could have a dedicated mgmt-thread that will receive
async-events from the shim. And all other user-land logic could consult
this mgmt-thread.


> Tom
Chetan Loke

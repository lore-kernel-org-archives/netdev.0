From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Thu, 2 Sep 2010 11:55:27 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D0670C9@nsmail.netscout.com>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com><1283356463.2556.351.camel@edumazet-laptop><AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com> <20100901.183251.106803238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <eric.dumazet@gmail.com>, <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, <Lee.Schermerhorn@hp.com>
To: "David Miller" <davem@davemloft.net>, <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og116.obsmtp.com ([64.18.1.37]:58514 "HELO
	exprod6og116.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755971Ab0IBPzb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 11:55:31 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100901.183251.106803238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> It's becomming increasingly obvious to me that we need (somewhere,
> not necessarily the kernel) a complete datastructure representing
> the NUMA, cache, cpu, device hierarchy.
> 
> And that can be used to tweak all of this stuff.
> 
> The policy should probably be in userspace, we just need to provide
> the knobs in the kernel to tweak it however userspace wants.
> 

I agree. But only if we have all the knobs in the kernel.

http://www.spinics.net/lists/linux-numa/msg00709.html

I had to do some changes manually. Thanks to Lee for pointing out the
dma-call.


> Userspace should be able to, for example, move a TX queue into a
> NUMA domain and have this invoke several side effects:
> 
> 1) IRQs for that TX queue get rerouted to a cpu in the NUMA
>    domain.
> 
> 2) TX queue datastructures in the driver get reallocated using
>    memory in that NUMA domain.
> 
> 3) TX hashing is configured to use the set of cpus in the NUMA
>    domain.
> 
> It's alot of tedious work and involves some delicate tasks figuring
> out where each of these things go, but really then we'd solve all
> of this crap one and for all.
> --

The MSI-X+MQ combo is something that should be taken care off. We could
come up with an automatic-node-binding shim in the kernel and then all
the sub-systems can use that.

Basically, the userland should query 
i) the adapter-capabilities 
ii)get the node-binding info
iii)and then start affinitizing everything


Some older msi-x (non-ethernet)adapters assume the msi-x info to remain
static once the adapter is initialized. If we had an auto-node-binding
shim then that would mean re-initializing the adapter,correct?



Chetan Loke

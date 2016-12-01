From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Thu, 1 Dec 2016 17:28:14 +0100
Message-ID: <20161201162814.GA31300@pox.localdomain>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f170.google.com ([209.85.210.170]:36428 "EHLO
        mail-wj0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753431AbcLAQ2R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:28:17 -0500
Received: by mail-wj0-f170.google.com with SMTP id qp4so209428481wjc.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:28:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/16 at 04:52pm, Hannes Frederic Sowa wrote:
> First of all, this is a rant targeted at XDP and not at eBPF as a whole.
> XDP manipulates packets at free will and thus all security guarantees
> are off as well as in any user space solution.
> 
> Secondly user space provides policy, acl, more controlled memory
> protection, restartability and better debugability. If I had multi
> tenant workloads I would definitely put more complex "business/acl"
> logic into user space, so I can make use of LSM and other features to
> especially prevent a network facing service to attack the tenants. If
> stuff gets put into the kernel you run user controlled code in the
> kernel exposing a much bigger attack vector.
> 
> What use case do you see in XDP specifically e.g. for container networking?

DDOS mitigation to protect distributed applications in large clusters.
Relying on CDN works to protect API gateways and frontends (as long as
they don't throw you out of their network) but offers no protection
beyond that, e.g. a noisy/hostile neighbour. Doing this at the server
level and allowing the mitigation capability to scale up with the number
of servers is natural and cheap.

> > I agree with you if the LB is a software based appliance in either a
> > dedicated VM or on dedicated baremetal.
> > 
> > The reality is turning out to be different in many cases though, LB
> > needs to be performed not only for north south but east west as well.
> > So even if I would handle LB for traffic entering my datacenter in user
> > space, I will need the same LB for packets from my applications and
> > I definitely don't want to move all of that into user space.
> 
> The open question to me is why is programmability needed here.
> 
> Look at the discussion about ECMP and consistent hashing. It is not very
> easy to actually write this code correctly. Why can't we just put C code
> into the kernel that implements this once and for all and let user space
> update the policies?

Whatever LB logic is put in place with native C code now is unlikely the
logic we need in two years. We can't really predict the future. If it
was the case, networking would have been done long ago and we would all
be working on self eating ice cream now.

> Load balancers have to deal correctly with ICMP packets, e.g. they even
> have to be duplicated to every ECMP route. This seems to be problematic
> to do in eBPF programs due to looping constructs so you end up with
> complicated user space anyway.

Feel free to implement such complex LBs in user space or natively. It is
not required for the majority of use cases. The most popular LBs for
application load balancing have no idea of ECMP and require ECMP aware
routers to be made redundant itself.

From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: atomic operations bottleneck in the IPv6 stack
Date: Wed, 10 Dec 2014 18:58:30 +0100
Message-ID: <1418234310.24395.5.camel@redhat.com>
References: <SN2PR03MB079DA7799199CD98C52B5389E620@SN2PR03MB079.namprd03.prod.outlook.com>
	 <1418231763.24395.2.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"R89243@freescale.com" <R89243@freescale.com>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	"Razvan.Ungureanu@freescale.com" <Razvan.Ungureanu@freescale.com>
To: "cristian.bercaru@freescale.com" <cristian.bercaru@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932479AbaLJS3y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 13:29:54 -0500
In-Reply-To: <1418231763.24395.2.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-12-10 at 18:16 +0100, Hannes Frederic Sowa wrote:
> On Mi, 2014-12-10 at 16:56 +0000, cristian.bercaru@freescale.com wrote:
> > 
> > It seems to me that the atomic operations on the IPv6 forwarding path
> > are a bottleneck and they are not scalable with the number of cores.
> > Am I right? What improvements can be brought to the IPv6 kernel code
> > to make it less dependent of atomic operations/variables?
> 
> For a starter, something like the following commit:
> 
> commit d26b3a7c4b3b26319f18bb645de93eba8f4bdcd5
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Tue Jul 31 05:45:30 2012 +0000
> 
>     ipv4: percpu nh_rth_output cache

Actually, we should be able to remove the atomics in input and
forwarding path by just relying on RCU. I'll have a look.

Bye,
Hannes

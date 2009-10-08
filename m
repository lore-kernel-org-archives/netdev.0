From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: using huge numbers of queues
Date: Fri, 9 Oct 2009 06:26:38 +1030
Message-ID: <20091009062638.1cd54c64@opy.nosense.org>
References: <c0a09e5c0910071459r2768f420lae87f7404dfbc054@mail.gmail.com>
	<20091007.153811.139592035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andy.grover@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adam.net.au ([202.136.110.253]:47356 "EHLO
	smtp1.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757313AbZJHT50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 15:57:26 -0400
In-Reply-To: <20091007.153811.139592035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 07 Oct 2009 15:38:11 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Grover <andy.grover@gmail.com>
> Date: Wed, 7 Oct 2009 14:59:49 -0700
> 
> > At NetConf, you made a passing remark about wanting lots of queues,
> > even 1-per-socket. Have you thought further about how we would use so
> > many?
> 
> Classification.
> 
> Lots and lots of virtual queues, which map to a smaller number
> of physical queues for delivery.
> 
> The virtual queue matched serves as a index and a classification
> hint to things like GRO receive, etc.

Is that similar to what is described in 

Trading Packet Headers for Packet Processing
http://www.sigcomm.org/sigcomm95/papers/chandranmenon.ps

?

My understanding of that paper is that when a packet enters the host it
is classified using various attributes e.g. Ip src/dest/etc, and then
assigned an unique identifier. Subsequent processing of the packet is
indexed by this identifier, rather than each processing stage
performing it's own packet classification and selection.

For packets that are forwarded, the packet is then tagged/labled with
an ID, so that subsequent hosts don't have to perform classification
either.

(This paper is pretty much the origins of MPLS, which is where my
original interest came from)


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

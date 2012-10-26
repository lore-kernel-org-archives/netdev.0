From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Regarding bottlenecks for high speed packet generation
Date: Fri, 26 Oct 2012 17:15:39 +0100
Message-ID: <1351268139.2584.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <CADAe=++9KHUx3qX+2==+q0Fq44CJ9tjYcO=HdLYOF3FVuM5Vtg@mail.gmail.com>
	 <CAD6jFUScXX0x7yU2f-Cq4B6RZdnQx4dkbADHBL9aYhzQmeKGgA@mail.gmail.com>
	 <CADAe=+L2hXpYwH-XyNS2HyHQrMQRCmV_v-bs0Qp+sR-mVkzV4A@mail.gmail.com>
	 <20121025.231814.962022530355865788.davem@davemloft.net>
	 <CADAe=+LSeTWTnDk3o46EiLMQqJ6q93yVP_D3J2Ufcfy-_cv6RA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <danborkmann@iogearbox.net>,
	<netdev@vger.kernel.org>
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:18074 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965038Ab2JZQPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 12:15:45 -0400
In-Reply-To: <CADAe=+LSeTWTnDk3o46EiLMQqJ6q93yVP_D3J2Ufcfy-_cv6RA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-26 at 11:42 +0530, Ajith Adapa wrote:
> > >
> > > But does NAPI comes into picture in case of transmission of packets ?
> >
> > Reclaim of TX descriptors occurs via NAPI.
> 
> You mean for every packet sent by the NIC card it drops a interrupt to
> reclaim the TX buffers used ?

Not necessarily; completions may be batched in some way.

> I am not able to understand why does NIC has to interrupt back instead
> of freeing the memory in background.
>
> Might be it does add some bottleneck in my case of transmitting traffic bursts.

The network core needs to account and limit how much memory is allocated
to socket buffers.  Completed TX buffers should therefore be freed
promptly, to avoid blocking the sending socket unnecessarily.  It
doesn't strictly matter whether this is triggered by an IRQ from the NIC
or by a timer, but it certainly must not be triggered by the next TX
initiation as this may result in a kind of deadlock.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 3/4] vxlan: remove gro_cell support
Date: Fri, 08 Jul 2016 11:06:25 +0200
Message-ID: <1467968785.4602.19.camel@redhat.com>
References: <cover.1467907022.git.pabeni@redhat.com>
	 <6f90239eb6ccb9145a886d4f01c6620c6d6ec87f.1467907022.git.pabeni@redhat.com>
	 <1467908002.1273.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44820 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754402AbcGHJGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 05:06:35 -0400
In-Reply-To: <1467908002.1273.42.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-07-07 at 18:13 +0200, Eric Dumazet wrote:
> On Thu, 2016-07-07 at 17:58 +0200, Paolo Abeni wrote:
> > GRO is now handled entirely by the udp_offload layer and  there is no need
> > for trying it again at the device level. We can drop gro_cell usage,
> > simplifying the driver a bit, while maintaining the same performance for
> > TCP and improving slightly for UDP.
> > This basically reverts the commit 58ce31cca1ff ("vxlan: GRO support
> > at tunnel layer")
> 
> Note that gro_cells provide GRO support after RPS, so this helps when we
> must perform TCP checksum computation, if NIC lacks CHECKSUM_COMPLETE
> 
> (Say we receive packets all steered to a single RX queue due to RSS hash
> being computed on outer header only)

You can still allow steering to multiple queues configuring an rx flow
hash computed on the outer l3 and l4 headers for udp, if supported by
your nic.

> Some people disable GRO on the physical device, but enable GRO on the
> tunnels.

I see. I'll resubmit only the first two patches. Allowing GRO on ingress
nic even for zero udp tunnel is still beneficial.

Paolo

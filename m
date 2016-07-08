From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/4] vxlan: remove gro_cell support
Date: Fri, 8 Jul 2016 11:12:05 -0400
Message-ID: <a7fd6676-4ba5-e1ec-7b57-9b4b7aee24be@stressinduktion.org>
References: <cover.1467907022.git.pabeni@redhat.com>
 <6f90239eb6ccb9145a886d4f01c6620c6d6ec87f.1467907022.git.pabeni@redhat.com>
 <1467908002.1273.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:56317 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754863AbcGHPMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 11:12:07 -0400
In-Reply-To: <1467908002.1273.42.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 07.07.2016 12:13, Eric Dumazet wrote:
> On Thu, 2016-07-07 at 17:58 +0200, Paolo Abeni wrote:
>> GRO is now handled entirely by the udp_offload layer and  there is no need
>> for trying it again at the device level. We can drop gro_cell usage,
>> simplifying the driver a bit, while maintaining the same performance for
>> TCP and improving slightly for UDP.
>> This basically reverts the commit 58ce31cca1ff ("vxlan: GRO support
>> at tunnel layer")
> 
> Note that gro_cells provide GRO support after RPS, so this helps when we
> must perform TCP checksum computation, if NIC lacks CHECKSUM_COMPLETE
> 
> (Say we receive packets all steered to a single RX queue due to RSS hash
> being computed on outer header only)
> 
> Some people disable GRO on the physical device, but enable GRO on the
> tunnels.

we are currently discussing your feedback and wonder how much it makes
sense to support such a scenario?

We have part of the inner hash in the outer UDP source port. So even the
outer hash does provide enough entropy to get frames of one tunnel on
multiple CPUs via hardware hashing - given that you don't care about OoO
for UDP (I infer that from the fact that RPS will also reorder UDP
frames in case of fragmentation).

I wonder why it makes sense to still take single RX queue nics into
consideration? We already provide support for multiqueue devices for
most VM-related interfaces as well. Can you describe why someone would
do such a scenario?

Thank you,
Hannes

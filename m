From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: UDP ordering when using multiple rx queue
Date: Wed, 11 Jul 2012 16:50:27 -0600
Message-ID: <4FFE0333.8040108@genband.com>
References: <CAL8zT=g5nHd6FprhxFc21XTgfXeaokt4QN1fS4ekcNVkuvZE9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og124.obsmtp.com ([64.18.2.26]:53634 "EHLO
	exprod7og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558Ab2GKWzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 18:55:49 -0400
In-Reply-To: <CAL8zT=g5nHd6FprhxFc21XTgfXeaokt4QN1fS4ekcNVkuvZE9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2012 01:53 AM, Jean-Michel Hautbois wrote:
> On receiver side, I need to get the packets ordered, or the
> application will consider the packets are late (and then, lost).
> (Yes, the application is badly written on that specific part, but it
> is not mine :)).

Not the first such app I've seen.

> Several tests lead to a simple conclusion : when the NIC has only one
> RX queue, everything is ok (like be2net for instance), but when it has
> more than one RX queue, then I can have "lost packets".
> This is the case for bnx2x or mlx4 for instance.

This depends on the hardware.  The Intel NICs for example (and others, 
I'm just most familiar with them) support multiple queues but they do 
hardware hashing of "flows" such that a given flow will be routed to a 
specific queue and thus stay in order.

> Here are my questions :
> - Is it possible to force a driver to use only one rx queue, even if
> it can use more without reloading the driver (and this is feasible
> only when a parameter exists for that !) ?

This depends on the driver, but generally I would expect this to be a 
module parameter.

> - Is it possible to "force" the network stack to give the packets on
> the correct order (I would say no, as this is not specified in the
> protocol) ?

No, it's up to the hardware/driver.


> My only bet is the first one (forcing one rx queue).
> The last and desperate solution would be rewriting the application,
> not easy to make it accepted.

Depending on the hardware/driver you may be able to enable flow hashing.

Chris

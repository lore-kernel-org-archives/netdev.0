From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: napi layer and packet throttling
Date: Thu, 23 May 2013 23:27:36 +0100
Message-ID: <1369348056.6963.25.camel@bwh-desktop.uk.level5networks.com>
References: <519E030E.5040903@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Holger Brunck <holger.brunck@keymile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19814 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759752Ab3EWW1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 18:27:41 -0400
In-Reply-To: <519E030E.5040903@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 13:52 +0200, Holger Brunck wrote:
> Hi all,
> I have a general question to the napi layer. I have a board with a MPC8360
> processor which uses the ucc_geth.c driver for it's ethernet device. The kernel
> version is 3.9. We see in lab tests that the board gets unresponsive if we send
> a high packet rate to this ethernet device via an packet generator. In the end
> we would like to limit the amount of incoming packets at a very early stage, to
> prevent the system of a to high softirq load.
> 
> The NAPI layer description I read on:
> http://www.linuxfoundation.org/collaborate/workgroups/networking/napi
> pointed two main functions out for the napi layer.
> 
> a) Interrupt mitigation
> Which works perfectly on the ucc_geth.c driver under high load the hard irqs for
> the RX packets are disabled and we switch to a polling mode. If the load is more
> relaxed we switch back.
> 
> b) Packet-Throttling
> Here the description says "NAPI-compliant drivers can often cause packets to be
> dropped in the network adaptor itself, before the kernel sees them at all."
> 
> This is exactly what I need for my usecase. But I don't see any hints how this
> can be implemented with the napi layer.
[...]

If the RX ring is not cleaned and refilled quickly enough, the network
controller will naturally start to drop packets.  It's not something you
should do explicitly in the driver.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

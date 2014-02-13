From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv4: arp: process only if ipv4 address configured
Date: Thu, 13 Feb 2014 01:24:13 +0100
Message-ID: <20140213002413.GK11150@order.stressinduktion.org>
References: <1392226067-21736-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50778 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbaBMAYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:24:14 -0500
Content-Disposition: inline
In-Reply-To: <1392226067-21736-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 06:27:47PM +0100, Florian Westphal wrote:
> 8030f54499925d073a88c09f ([IPV4] devinet: Register inetdev earlier.)
> changed arp behaviour (2.6.22 onwards).
> 
> Before this, inetdev_init() was called only when the first address was
> added to the interface, i.e. arp_process always dropped incoming arp
> packets as __in_dev_get_rcu() returned NULL when no IP address was set
> on the interface.
> 
> With >= 2.6.22 we now process arp packets even if no address is assigned.
> It can cause issues if the machine has several interfaces in the same
> segment; requests receive answers from multiple macs.

I actually expect arp answers for ip addresses bound to loopback even from an
interface without ip address, if we strictly conform to the week end host
model in linux.

This is e.g. a common setup for BGP routers, where you assign the IBGP
address to loopback or dummy and thus make it interface independent.

Greetings,

  Hannes

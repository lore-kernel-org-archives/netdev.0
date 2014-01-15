From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Route exceptions for IPv6 routes?
Date: Wed, 15 Jan 2014 12:51:15 +0100
Message-ID: <20140115115115.GD19945@order.stressinduktion.org>
References: <trinity-d0560a1c-2418-449e-b478-ebc707cea8e5-1389772882296@3capp-gmx-bs10>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38986 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbaAOLvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 06:51:16 -0500
Content-Disposition: inline
In-Reply-To: <trinity-d0560a1c-2418-449e-b478-ebc707cea8e5-1389772882296@3capp-gmx-bs10>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Wed, Jan 15, 2014 at 09:01:22AM +0100, Simon Schneider wrote:
> I learned that the routing cache was removed from the kernel for several reasons.
> 
> Some functions have been replaced with the route exceptions, e.g. storing the path MTU.
> 
> My question: is this valid for both IPv4 as well as IPv6 routing, i.e. do the route exceptions work in the same way for IPv6 routes as they work for IPv4 routes?

No, situation in IPv6 land is not so good.

Currently as soon as a destination (or destination + source in case of
subtrees are in use) is resolved the routing entry is cloned and stored back
into the same trie with RTF_CACHE flag.

There are no nh-exceptions and there is no aggressive sharing taking place to
try to reduce the number of exceptions. This is especially bad for forwarding
setups, but seems to work fine for most people currently. ;)

Actually, implementing this is part of the work I am currently doing
but this needs still time until I can manage to propose this for upstream.

Greetings,

  Hannes

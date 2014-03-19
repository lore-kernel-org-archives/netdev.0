From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: If a public address is deleted then also delete all temporary addresses still referring to it
Date: Wed, 19 Mar 2014 21:21:23 +0100
Message-ID: <20140319202123.GH12291@order.stressinduktion.org>
References: <5328B0B0.7070305@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Heiner Kallweit <heiner.kallweit@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46996 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbaCSUVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 16:21:25 -0400
Content-Disposition: inline
In-Reply-To: <5328B0B0.7070305@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 09:46:40PM +0100, Heiner Kallweit wrote:
> If a public address is deleted by an external trigger (e.g. via inet6_rtm_deladdr) then temporary
> addresses still referring to it may remain. Happened here when the WiFi link broke and netifd
> deleted the public address. Once the link was back and prefix_rcv created new public addresses
> ipv6_create_tempaddr complained that the temporary address already existed.

Which error was it specifically?

> IMHO no temporary address should live longer than its parent, especially because ifpub of the
> temporary address still points to the then deleted public address otherwise.

Reference counting will take care of that.

> Therefore delete all related temporary addresses before a public address is deleted in inet6_addr_del
> which is called by inet6_rtm_del.

I am a bit concerend with backward compatibility here.

> Also ensure in ipv6_del_addr that no temporary address lives longer than its parent.

I currently don't see a problem with that.

Greetings,

  Hannes

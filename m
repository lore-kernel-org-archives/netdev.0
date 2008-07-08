From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan tag by hand
Date: Tue, 8 Jul 2008 23:10:17 +0100
Message-ID: <20080708221016.GJ28029@solarflare.com>
References: <20080707205646.GB12997@xi.wantstofly.org> <4872841E.1030609@trash.net> <20080707210701.GD12997@xi.wantstofly.org> <48728784.2030202@trash.net> <487394CC.7050107@trash.net> <20080708185226.GD14330@xi.wantstofly.org> <4873B6E1.9010702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:51145 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755290AbYGHWKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 18:10:24 -0400
Content-Disposition: inline
In-Reply-To: <4873B6E1.9010702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
[...]
> Without checking if its actually needed, I would tend to agree because
> a caller can't rely on getting a linearized skb back except when its
> guaranteed to be cloned, in the case it could simply copy it always.
> 
> Anyway, the copy in __vlan_put_tag() is overkill since the header
> is usually writable. See the patch I sent in my second mail, it
> should reduce the overhead significantly.
> 
> Actually there was a small bug in the one I sent, so attached again
> to this mail.

This looks great.  Since our controller doesn't do VLAN tag insertion, I
ran some quick tests and it improved TCP throughput over VLAN devices
without TSO by about 50%.  (With TSO on, the change wasn't so great - I
think this was because the receive side couldn't do LRO on tagged
packets.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.

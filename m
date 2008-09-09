From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after some time
Date: Tue, 9 Sep 2008 00:17:35 -0700
Message-ID: <OF3335B3DD.83510AA3-ON882574BF.00275BAF-882574BF.00281037@us.ibm.com>
References: <63ca0b47d6921cd641bb3ca26ab20baa@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bernhard Schmidt <berni@birkenwald.de>,
	Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:40261 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbYIIHRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 03:17:38 -0400
In-Reply-To: <63ca0b47d6921cd641bb3ca26ab20baa@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 09/08/2008 11:52:05 PM:

> 
> On Tue, 9 Sep 2008 02:38:53 +0200, Bernhard Schmidt 
<berni@birkenwald.de>
> 
> wrote:
> 
> > ff00::/8 dev teredo  metric 256  mtu 1280 advmss 1220 hoplimit 
4294967295
> 
>                ^^^^^^
> 
> Uho... that interface is not multicast-capable. Not sure how the kernel
> 
> handles the conflicting routes.

        Multicast programs shouldn't rely on the routing
table at all, IMAO. Unicast routing has nothing at all
to do with multicast routing, where a single address
means copying and forwarding to multiple different
segments, and the address has nothing at all to do with
the routing topology.
        That's why the scope_id should be set (and to
the proper index for eth0), but I think either strace
is lying to us here or they're using SO_BINDTODEVICE
or IP_MULTICAST_IF.
        But when it's breaking, I imagine it is ending
up on the wrong interface and thus the EINVAL... I
just don't see how some addresses still work while
others fail at the same time. :-)

                                                +-DLS


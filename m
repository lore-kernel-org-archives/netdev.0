From: Patrick McHardy <kaber@trash.net>
Subject: Re: Is it valid to add a macvlan virtual interface to a bridge? If
 so, there seems to be a bug with it.
Date: Mon, 12 Jan 2009 05:55:25 +0100
Message-ID: <496ACD3D.6000608@trash.net>
References: <E1LD9nz-0007sR-OP@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ipng@69706e6720323030352d30312d31340a.nosense.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55354 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbZALEzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 23:55:40 -0500
In-Reply-To: <E1LD9nz-0007sR-OP@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Patrick McHardy <kaber@trash.net> wrote:
>>> I've had a look at the dev.c file in 2.6.27, and my very naive guess
>>> is that as the handle_bridge() call is before the handle_macvlan() call,
>>> because the incoming real physical interface is not part of the bridge,
>>> the incoming unicast packet is being dropped, before the macvlan code
>>> gets a look at it.
>> Yes, that seems correct.
> 
> Would it be possible to implement promiscuous mode for macvlans by
> simply keeping a separate list of macvlan devices in promiscuous
> mode and sending all inbound packets to them?
> 
> This should make bridging work, right?

I think that should work, at least if we also put the underlying device
in promiscous mode. It wouldn't really be *mac*vlan anymore though :)

I've put it on my TODO list, though I won't be able to take care
of this any time soon.

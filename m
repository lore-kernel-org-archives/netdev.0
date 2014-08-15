From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Thu, 14 Aug 2014 19:01:25 -0700
Message-ID: <1408068085.6804.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
	 <1408064099.6804.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1408064641.867439.152913861.09367C24@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59486 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415AbaHOCBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 22:01:35 -0400
Received: by mail-pa0-f45.google.com with SMTP id eu11so2684837pac.32
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 19:01:34 -0700 (PDT)
In-Reply-To: <1408064641.867439.152913861.09367C24@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-08-15 at 03:04 +0200, Hannes Frederic Sowa wrote:

> Sure, but if I would have written such a tool without knowledge of GRO I
> would have queried at least the MTU. ;)

Would all existing tools react to a mtu change properly ?

(It would have to reinit its af_packet ring)

I do not think its a GRO issue, really, but an optimistic PACKET_V3
implementation. GRO was already there when PACKET_V3 was added.

Even a non GRO packet might not fit and we need to avoid the
crash/corruption.

I believe I am going to implement 2)  (clamp the snaplen)

An application should catch that tp_len might be bigger than tp_snaplen
and eventually do something sensible about it.

BTW, tp_sizeof_priv doesnt look to be checked at all, user input is
accepted as is.

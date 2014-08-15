From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Thu, 14 Aug 2014 17:54:59 -0700
Message-ID: <1408064099.6804.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
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
Received: from mail-pd0-f175.google.com ([209.85.192.175]:46939 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaHOAzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 20:55:01 -0400
Received: by mail-pd0-f175.google.com with SMTP id r10so2486289pdi.20
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 17:55:00 -0700 (PDT)
In-Reply-To: <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-08-15 at 02:43 +0200, Hannes Frederic Sowa wrote:

> Someone could use GRO to create packet trains to hide from intrustion
> detection systems, which maybe are the main user of TPACKET_V3. I don't
> think this is a good idea.

Presumably these tools already use a large enough bloc_size, and not a
4KB one ;)

Even without GRO, a jumbo frame (9K) can trigger the bug.

I do not think we need to skb_gso_segment() for the cases user setup a
really small bloc_size. This looks like a lot of consumed cycles (we
even might have to recompute the TCP checksums)

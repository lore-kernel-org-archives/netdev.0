From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/4] Revert "inet: limit length of fragment
 queue hash table bucket lists"
Date: Wed, 24 Apr 2013 17:00:30 -0700
Message-ID: <1366848030.8964.98.camel@edumazet-glaptop>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154800.16883.4797.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:40530 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758416Ab3DYAAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 20:00:33 -0400
Received: by mail-da0-f54.google.com with SMTP id s35so1122770dak.27
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 17:00:32 -0700 (PDT)
In-Reply-To: <20130424154800.16883.4797.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> This reverts commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055.
> 
> The problem with commit 5a3da1fe (inet: limit length of fragment queue
> hash table bucket lists) is that, once we hit the hash depth limit (of
> 128), the we *keep* the existing frag queues, not allowing new frag
> queues to be created.  Thus, an attacker can effectivly block handling
> of fragments for 30 sec (as each frag queue have a timeout of 30 sec)
> 

I do not think its good to revert this patch. It was a step in right
direction.

Limiting chain length to 128 is good.

An attacker can attack a defrag unit, no matter strategy you use, thats
why fragments are doomed.

The only way to resist to an attack is to have enough memory in defrag
unit to accumulate 30 seconds worth of traffic.

Thats 30GB of memory if you receive 1GB per second, bit counting the
overhead.

If the attacker knows the IP address of the user of your defrag unit,
you are doomed because IP id are 16bits.

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Poor UDP throughput with virtual devices and UFO
Date: Mon, 27 Oct 2014 08:39:48 -0700
Message-ID: <1414424388.16231.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414405781.4492.38.camel@ubuntu-vm-makita>
	 <1414422089.16231.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <edumazet@google.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:54583 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbaJ0Pjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 11:39:49 -0400
Received: by mail-pd0-f173.google.com with SMTP id v10so5883520pde.32
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 08:39:49 -0700 (PDT)
In-Reply-To: <1414422089.16231.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-27 at 08:01 -0700, Eric Dumazet wrote:

> Please rewrite your patch to move the code out of tcp_gso_segment() into
> skb_segment()
> 
> Look how I carefully avoided many atomic operations on
> sk->sk_wmem_alloc, but how you removed it. :(
> 
> Alternative would be to use a single skb_set_owner_w() on the last
> segment, and tweak its truesize to not corrupt sk->sk_wmem_alloc
> 
> d6a4a1041176 was needed for people using GSO=off TSO=off on a bonding
> device, while best performance is reached with TSO=on so that
> segmentation is performed later on the slave device.

Hmm.. I meant 6ff50cd55545d92 ("tcp: gso: do not generate out of order
packets")

I think I will test an alternative patch and send it, keeping you as the
author if you do not mind.

Thanks.

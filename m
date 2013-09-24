From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Add function to get SW rxhash
Date: Tue, 24 Sep 2013 10:03:00 -0700
Message-ID: <1380042180.3165.102.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309240915001.24581@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:54254 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449Ab3IXRDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 13:03:01 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so4812062pdj.8
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 10:03:01 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1309240915001.24581@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 09:20 -0700, Tom Herbert wrote:
> Some uses of skb_get_rxhash expect that the function will return
> a consistent value whether it is called on RX or TX paths. On RX
> path, we will use the rxhash if provided by the NIC, so this
> would not normally be the same result computed in TX path which is
> a software calculation.
> 
> This patch adds skb_get_sw_rxhash to explicitly request a hash
> calculated by the stack, disregarding the hash provided by NIC.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

1) Adding another skb field for this corner case, is it worth it ?
   Computing rxhash in software should be real fast for the
   cases where we really care of symmetry.

  ie ignore skb->rxhash and use __skb_get_rxhash()

2) Not copying sw_rxhash in __copy_skb_header()

   -> value will be undefined after a clone()

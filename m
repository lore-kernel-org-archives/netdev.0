From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: use tcp_flags in tcp_data_queue()
Date: Wed, 24 Sep 2014 06:22:28 -0700
Message-ID: <1411564948.15395.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411556068.15395.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <c02ed73dc0aa5bf5bdd479ec49403728db8e73c6.1411562110.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:58310 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbaIXNWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 09:22:24 -0400
Received: by mail-pd0-f172.google.com with SMTP id y10so8684703pdj.31
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 06:22:24 -0700 (PDT)
In-Reply-To: <c02ed73dc0aa5bf5bdd479ec49403728db8e73c6.1411562110.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-24 at 20:42 +0800, Weiping Pan wrote:
> Follow the idea in commit e11ecddf5128 (tcp: use TCP_SKB_CB(skb)->tcp_flags in
> input path), we can use tcp_flags to avoid cache miss.
> 

Well, there is no cache miss here. Lets try to have precise changelogs.

We access tcp_hdr(skb)->doff right before, so the tcp header is in cpu
cache.

So this patch is a cleanup and a way to help compiler to reduce register
pressure since skb->cb[] access is fast (skb is probably in a register)

Thanks.

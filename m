From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] tcp: add NV congestion control
Date: Fri, 03 Jul 2015 19:10:18 +0200
Message-ID: <1435943418.11970.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435886484-1709996-1-git-send-email-brakmo@fb.com>
	 <1435899623.11970.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150703.093715.1504840554531952050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brakmo@fb.com, netdev@vger.kernel.org, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:34833 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180AbbGCRKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 13:10:22 -0400
Received: by wgjx7 with SMTP id x7so92849121wgj.2
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 10:10:21 -0700 (PDT)
In-Reply-To: <20150703.093715.1504840554531952050.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-03 at 09:37 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 03 Jul 2015 07:00:23 +0200
> 
> > tcp_skb_cb is currently 44 bytes, so even if you add one u32, it should
> > not exceed cb[]
> 
> Please see sock_skb_cb, which consumes space in skb->cb[] in parallel
> with things like tcp_skb_cb.  The usage of skb->cb[] therefore really
> is 48 bytes and I'm sure the build time assertions triggered if
> Lawrence added the new tcp_skb_cb member without first increasing it's
> size.

Oh... this part is completely buggy then.
We should revert net/ipv4/tcp.c change added in commit 

 b4772ef879a8f7d8c56118c2ae5a296fcf6f81d2

    net: use common macro for assering skb->cb[] available size in
protocol families

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v3 1/2] net: sched: tbf: fix calculation of max_size
Date: Sat, 23 Nov 2013 11:06:19 -0800
Message-ID: <1385233579.10637.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>
	 <1384845939-8424-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:40286 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755987Ab3KWTGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 14:06:22 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so3080329pbb.17
        for <netdev@vger.kernel.org>; Sat, 23 Nov 2013 11:06:22 -0800 (PST)
In-Reply-To: <1384845939-8424-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-19 at 15:25 +0800, Yang Yingliang wrote:
> commit b757c9336d63f94c6b57532(tbf: improved accuracy at high rates)
> introduce a regression.
> 
> With the follow command:
> tc qdisc add dev eth1 root handle 1: tbf latency 50ms burst 10KB rate 30gbit mtu 64k
> 
> Without this patch, the max_size value is 10751(bytes).
> But, in fact, the real max_size value should be smaller than 7440(bytes).
> Or a packet whose length is bigger than 7440 will cause network congestion.
> Because the packet is so big that can't get enough tokens. Even all the tokens
> in the buffer is given to the packet.
> 
> With this patch, the max_size value is 7440(bytes).
> The packets whose length is bigger than 7440(bytes) will be dropped or reshape
> in tbf_enqueue().

This changelog makes no sense.

If userland asks 'burst 10KB', then burst is 10KB, not 7440.

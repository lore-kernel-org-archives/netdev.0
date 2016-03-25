From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFT Patch net 1/2] ipv6: invalidate the socket cached route on
 pmtu events if possible
Date: Thu, 24 Mar 2016 18:51:20 -0700
Message-ID: <1458870680.6473.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1458851740.12033.24.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpVDN_LPsa2XgVWoqMjrOYpg9JNjPJVwEvTuxPgYyWRWmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Wei Wang <weiwan@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36768 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbcCYBvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 21:51:24 -0400
Received: by mail-pa0-f49.google.com with SMTP id tt10so35892214pab.3
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 18:51:23 -0700 (PDT)
In-Reply-To: <CAM_iQpVDN_LPsa2XgVWoqMjrOYpg9JNjPJVwEvTuxPgYyWRWmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-24 at 17:15 -0700, Cong Wang wrote:

> My understanding is that bh_lock_sock() prevents concurrent
> access to sock struct. Since this is in softirq context, multiple
> CPU's could call this function concurrently, the whole pmtu
> update needs to be done atomically.
> 
> UDP, on the other hand, doesn't do this logic, it just looks up
> for dst and save it in sk_dst_cache.

Two ICMP messages processed on two different cpus can still get two
different sockets pointing to the same dst.

I do not see how dst pmtu update could be protected by a lock on each
socket. It would require a dst lock , or some simple memory writes that
do not require special synchro.

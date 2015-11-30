From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: kill sk_dst_lock
Date: Mon, 30 Nov 2015 10:27:32 -0800
Message-ID: <1448908052.24696.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+Y=35aC5DK7MQaDF6eviKcXik2S9caTLw7FAp0L0CXdsg@mail.gmail.com>
	 <1448730683.24696.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448731434.24696.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448854142.24696.109.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448901315.24696.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448907188.5804.31.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34699 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899AbbK3S1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 13:27:34 -0500
Received: by padhx2 with SMTP id hx2so192399640pad.1
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 10:27:33 -0800 (PST)
In-Reply-To: <1448907188.5804.31.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-30 at 19:13 +0100, Paolo Abeni wrote:
> On Mon, 2015-11-30 at 08:35 -0800, Eric Dumazet wrote:
> > ip6_sk_dst_lookup_flow() uses sk_dst_check() anyway, so the simplest
> > way to fix the mess is to remove sk_dst_lock completely, as we did for
> > IPv4.
> 
> Probably I'm missing something here, but why we don't need to sync the
> update of sk_dst_cache and of dst_cookie (i.e. put them under the same
> lock)?
> 
> Can't we end up with inconsistent values after concurrent udp
> sendmsg() ? 

I do not think this is an issue. A route is best effort.

If really a packet is dropped during a route flap, no big deal,
especially if this is during a fuzzer test ;)

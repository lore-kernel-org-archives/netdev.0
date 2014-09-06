From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Sat, 06 Sep 2014 07:45:04 -0700
Message-ID: <1410014704.11872.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ED4354.9090904@intel.com>
	 <20140814.162024.2218312002979492106.davem@davemloft.net>
	 <CA+mtBx-c0HCAES9PCyGn7cChZsX0KaLgdziFL_e1iRmkdG0dsQ@mail.gmail.com>
	 <20140821.162406.2076033247433267586.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:47862 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbaIFOpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 10:45:06 -0400
Received: by mail-pd0-f181.google.com with SMTP id fp1so17401443pdb.26
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 07:45:06 -0700 (PDT)
In-Reply-To: <20140821.162406.2076033247433267586.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-21 at 16:24 -0700, David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Thu, 14 Aug 2014 16:25:53 -0700
> 
> > I don't know if it's the same problem, but I did post a patch back in
> > January that would resolve false sharing of dst->__refcnt and rt_genid
> > in the same cacheline. We could revisit that if it helps.
> 
> I think that regardless of what happens in the discussion here, you
> should repost that patch.

I believe this wont be necessary, the real meat is elsewhere.

There are very few cases where we really need to keep the dst attached
to skb.

Its mostly because of IP early demux, and its possible to take care of
the fast path (where sk->sk_rx_dst is set), and simply drop dst before
prequeue in this case.

Same stuff for the backlog, used when socket is owned by user.

I'll send a patch.

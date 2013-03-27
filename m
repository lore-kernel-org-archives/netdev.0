From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/3] net: frag, avoid several CPUs grabbing
 same frag queue during LRU evictor loop
Date: Wed, 27 Mar 2013 09:14:04 -0700
Message-ID: <1364400844.15753.18.camel@edumazet-glaptop>
References: <20130327155238.15203.6688.stgit@dragon>
	 <20130327155457.15203.69656.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f173.google.com ([209.85.210.173]:35248 "EHLO
	mail-ia0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab3C0QOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 12:14:07 -0400
Received: by mail-ia0-f173.google.com with SMTP id h37so7535514iak.18
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 09:14:06 -0700 (PDT)
In-Reply-To: <20130327155457.15203.69656.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 16:55 +0100, Jesper Dangaard Brouer wrote:
> The LRU list is protected by its own lock, since commit 3ef0eb0db4
> (net: frag, move LRU list maintenance outside of rwlock), and
> no-longer by a read_lock.
> 
> This makes it possible, to remove the inet_frag_queue, which is about
> to be "evicted", from the LRU list head.  This avoids the problem, of
> several CPUs grabbing the same frag queue.
> 
> Note, cannot remove the inet_frag_lru_del() call in fq_unlink()
> called by inet_frag_kill(), because inet_frag_kill() is also used in
> other situations.  Thus, we use list_del_init() to allow this
> double list_del to work.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
> 
>  net/ipv4/inet_fragment.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 

Acked-by: Eric Dumazet <edumazet@google.com>

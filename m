From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: frag, fix race conditions in LRU list maintenance
Date: Sun, 5 May 2013 20:30:21 +0200
Message-ID: <20130505183021.GB19796@breakpoint.cc>
References: <20130505145622.9351.86587.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, linux-kernel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130505145622.9351.86587.stgit@zurg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:
> This patch fixes race between inet_frag_lru_move() and inet_frag_lru_add()
> which was introduced in commit 3ef0eb0db4bf92c6d2510fe5c4dc51852746f206
> ("net: frag, move LRU list maintenance outside of rwlock")
> 
> One cpu already added new fragment queue into hash but not into LRU.
> Other cpu found it in hash and tries to move it to the end of LRU.
> This leads to NULL pointer dereference inside of list_move_tail().
>
> Another possible race condition is between inet_frag_lru_move() and
> inet_frag_lru_del(): move can happens after deletion.

True, thanks for fixing this problem.

> This patch initializes LRU list head before adding fragment into hash and
> inet_frag_lru_move() doesn't touches it if it's empty.

Acked-by: Florian Westphal <fw@strlen.de>

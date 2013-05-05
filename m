From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: frag, fix race conditions in LRU list maintenance
Date: Sun, 05 May 2013 13:36:42 -0400 (EDT)
Message-ID: <20130505.133642.523571665638952150.davem@davemloft.net>
References: <20130505145622.9351.86587.stgit@zurg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, fw@strlen.de,
	linux-kernel@vger.kernel.org, brouer@redhat.com
To: khlebnikov@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130505145622.9351.86587.stgit@zurg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sun, 05 May 2013 18:56:22 +0400

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
> 
> This patch initializes LRU list head before adding fragment into hash and
> inet_frag_lru_move() doesn't touches it if it's empty.
> 
> I saw this kernel oops two times in a couple of days.
 ...
> Oops happened on this path:
> ip_defrag() -> ip_frag_queue() -> inet_frag_lru_move() -> list_move_tail() -> __list_del_entry()
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

This looks good to me, Jesper and co. please review.

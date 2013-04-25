From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/3] unix/dgram: peek beyond 0-sized skbs
Date: Thu, 25 Apr 2013 11:48:56 -0700
Message-ID: <1366915736.8964.171.camel@edumazet-glaptop>
References: <1366897638-21882-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366897638-21882-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-25 at 09:47 -0400, Benjamin Poirier wrote:
> "77c1090 net: fix infinite loop in __skb_recv_datagram()" (v3.8) introduced a
> regression:
> After that commit, recv can no longer peek beyond a 0-sized skb in the queue.
> __skb_recv_datagram() instead stops at the first skb with len == 0 and results
> in the system call failing with -EFAULT via skb_copy_datagram_iovec().


if MSG_PEEK is not used, what happens here ?

It doesn't look right to me that we return -EFAULT if skb->len is 0,
EFAULT is reserved to faulting (ie reading/writing at least one byte)

How are we telling the user message had 0 byte, but its not EOF ?

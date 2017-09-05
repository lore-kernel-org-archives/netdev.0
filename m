From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rxrpc: Make service connection lookup always
 check for retry
Date: Tue, 05 Sep 2017 14:41:53 -0700 (PDT)
Message-ID: <20170905.144153.67687828247988369.davem@davemloft.net>
References: <150453530801.20359.17059994007095255872.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150453530801.20359.17059994007095255872.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Mon, 04 Sep 2017 15:28:28 +0100

> When an RxRPC service packet comes in, the target connection is looked up
> by an rb-tree search under RCU and a read-locked seqlock; the seqlock retry
> check is, however, currently skipped if we got a match, but probably
> shouldn't be in case the connection we found gets replaced whilst we're
> doing a search.
> 
> Make the lookup procedure always go through need_seqretry(), even if the
> lookup was successful.  This makes sure we always pick up on a write-lock
> event.
> 
> On the other hand, since we don't take a ref on the object, but rely on RCU
> to prevent its destruction after dropping the seqlock, I'm not sure this is
> necessary.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.

From: David Miller <davem@davemloft.net>
Subject: Re: A possible bug in reqsk_queue_hash_req()
Date: Tue, 20 Apr 2010 14:24:05 -0700 (PDT)
Message-ID: <20100420.142405.228805796.davem@davemloft.net>
References: <i2x9b948ee41004200335vc229a59cvc0a08c35c949d7dd@mail.gmail.com>
	<1271761611.3845.223.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raise.sail@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1271761611.3845.223.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Apr 2010 13:06:51 +0200

> I believe its not really necessary, because we are the only possible
> writer at this stage.
> 
> The write_lock() ... write_unlock() is there only to enforce a
> synchronisation with readers.
> 
> All callers of this reqsk_queue_hash_req() must have the socket locked

Right.

In fact there are quite a few snippets around the networking
where we use this trick of only locking around the single
pointer assignment that puts the object into the list.

And they were all written by Alexey Kuznetsov, so they must
be correct :-)

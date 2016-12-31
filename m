From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: socket: don't set sk_uid to garbage value in
 ->setattr()
Date: Sat, 31 Dec 2016 12:36:35 -0500 (EST)
Message-ID: <20161231.123635.849464145094515334.davem@davemloft.net>
References: <20161230234232.4221-1-ebiggers3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        ebiggers@google.com
To: ebiggers3@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161230234232.4221-1-ebiggers3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Biggers <ebiggers3@gmail.com>
Date: Fri, 30 Dec 2016 17:42:32 -0600

> From: Eric Biggers <ebiggers@google.com>
> 
> ->setattr() was recently implemented for socket files to sync the socket
> inode's uid to the new 'sk_uid' member of struct sock.  It does this by
> copying over the ia_uid member of struct iattr.  However, ia_uid is
> actually only valid when ATTR_UID is set in ia_valid, indicating that
> the uid is being changed, e.g. by chown.  Other metadata operations such
> as chmod or utimes leave ia_uid uninitialized.  Therefore, sk_uid could
> be set to a "garbage" value from the stack.
> 
> Fix this by only copying the uid over when ATTR_UID is set.
> 
> Fixes: 86741ec25462 ("net: core: Add a UID field to struct sock.")
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Lorenzo, please review.

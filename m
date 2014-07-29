From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sendmsg: fix NULL pointer dereference
Date: Tue, 29 Jul 2014 12:21:06 -0700 (PDT)
Message-ID: <20140729.122106.1193653186424252040.davem@davemloft.net>
References: <1406390080.22881.75.camel@localhost>
	<1406395618-4697-1-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, edumazet@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sasha.levin@oracle.com, a.ryabinin@samsung.com,
	stable@vger.kernel.org
To: ryabinin.a.a@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1406395618-4697-1-git-send-email-a.ryabinin@samsung.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Date: Sat, 26 Jul 2014 21:26:58 +0400

> Sasha's report:
 ...
> This reports means that we've come to netlink_sendmsg() with msg->msg_name == NULL and msg->msg_namelen > 0.
> 
> After this report there was no usual "Unable to handle kernel NULL pointer dereference"
> and this gave me a clue that address 0 is mapped and contains valid socket address structure in it.
> 
> This bug was introduced in f3d3342602f8bcbf37d7c46641cb9bca7618eb1c
> (net: rework recvmsg handler msg_name and msg_namelen logic).
> Commit message states that:
> 	"Set msg->msg_name = NULL if user specified a NULL in msg_name but had a
> 	 non-null msg_namelen in verify_iovec/verify_compat_iovec. This doesn't
> 	 affect sendto as it would bail out earlier while trying to copy-in the
> 	 address."
> But in fact this affects sendto when address 0 is mapped and contains
> socket address structure in it. In such case copy-in address will succeed,
> verify_iovec() function will successfully exit with msg->msg_namelen > 0
> and msg->msg_name == NULL.
> 
> This patch fixes it by setting msg_namelen to 0 if msg_name == NULL.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: <stable@vger.kernel.org>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

Applied and queued up for -stable, thanks!

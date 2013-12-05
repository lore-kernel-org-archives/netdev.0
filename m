From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: handle error more gracefully in socketpair()
Date: Thu, 05 Dec 2013 16:23:33 -0500 (EST)
Message-ID: <20131205.162333.1525865133149454763.davem@davemloft.net>
References: <1385977019-12282-1-git-send-email-ydroneaud@opteya.com>
	<1385979146-13825-1-git-send-email-ydroneaud@opteya.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
To: ydroneaud@opteya.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385979146-13825-1-git-send-email-ydroneaud@opteya.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yann Droneaud <ydroneaud@opteya.com>
Date: Mon,  2 Dec 2013 11:12:26 +0100

> socketpair() error paths can be simplified to not call
> heavy-weight sys_close().
> 
> This patch makes socketpair() use of error paths which do not
> rely on heavy-weight call to sys_lose(): it's better to try
> to push the file descriptor to userspace before installing
> the socket file to the file descriptor, so that errors are
> catched earlier and being easier to handle.
> 
> Three distinct error paths are needed since calling fput()
> on file structure returned by sock_alloc_file() will
> implicitly call sock_release() on the associated socket
> structure.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Yann Droneaud <ydroneaud@opteya.com>
> Link: http://marc.info/?i=1385977019-12282-1-git-send-email-ydroneaud@opteya.com

I know that sys_close() is expensive, _but_ erroring out on
the put_user() is extremely rare and logically it makes
a ton more sense to fully install a file descriptor before
writing it's numeric value into userspace.

Sorry, I think the current code is fine and I'm not going
to apply this, thanks.

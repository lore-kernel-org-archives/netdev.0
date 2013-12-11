From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: handle error more gracefully in socketpair()
Date: Tue, 10 Dec 2013 22:24:29 -0500 (EST)
Message-ID: <20131210.222429.1538443980618684288.davem@davemloft.net>
References: <20131206104805.GM10323@ZenIV.linux.org.uk>
	<20131206.121411.2205219888474731457.davem@davemloft.net>
	<1386625340-8490-1-git-send-email-ydroneaud@opteya.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ydroneaud@opteya.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386625340-8490-1-git-send-email-ydroneaud@opteya.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yann Droneaud <ydroneaud@opteya.com>
Date: Mon,  9 Dec 2013 22:42:20 +0100

> This patch makes socketpair() use error paths which do not
> rely on heavy-weight call to sys_close(): it's better to try
> to push the file descriptor to userspace before installing
> the socket file to the file descriptor, so that errors are
> catched earlier and being easier to handle.
> 
> Using sys_close() seems to be the exception, while writing the
> file descriptor before installing it look like it's more or less
> the norm: eg. except for code used in init/, error handling
> involve fput() and put_unused_fd(), but not sys_close().
> 
> This make socketpair() usage of sys_close() quite unusual.
> So it deserves to be replaced by the common pattern relying on
> fput() and put_unused_fd() just like, for example, the one used
> in pipe(2) or recvmsg(2).
> 
> Three distinct error paths are still needed since calling
> fput() on file structure returned by sock_alloc_file() will
> implicitly call sock_release() on the associated socket
> structure.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Yann Droneaud <ydroneaud@opteya.com>
> Link: http://marc.info/?i=1385979146-13825-1-git-send-email-ydroneaud@opteya.com

Applied to net-next, thanks.

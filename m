From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Thu, 22 May 2008 22:22:46 -0700
Message-ID: <20080522222246.0526f8f8.akpm@linux-foundation.org>
References: <200805062118.m46LI74j004096@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45723 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751452AbYEWFXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 01:23:35 -0400
In-Reply-To: <200805062118.m46LI74j004096@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 May 2008 17:18:07 -0400 Ulrich Drepper <drepper@redhat.com> wrote:

> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1219,6 +1219,13 @@ asmlinkage long sys_socket(int family, int type, int protocol)
>  	struct socket *sock;
>  	int flags;
>  
> +	/* Check the SOCK_* constants for consistency.  */
> +	BUILD_BUG_ON(SOCK_CLOEXEC != O_CLOEXEC);
> +	BUILD_BUG_ON(SOCK_NONBLOCK != O_NONBLOCK);
> +	BUILD_BUG_ON((SOCK_MAX | SOCK_TYPE_MASK) != SOCK_TYPE_MASK);
> +	BUILD_BUG_ON(SOCK_CLOEXEC & SOCK_TYPE_MASK);
> +	BUILD_BUG_ON(SOCK_NONBLOCK & SOCK_TYPE_MASK);

On alpha the

	BUILD_BUG_ON(SOCK_NONBLOCK & SOCK_TYPE_MASK);

seems to have gone away, but now

	BUILD_BUG_ON(SOCK_NONBLOCK != O_NONBLOCK);

is triggering.


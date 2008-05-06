From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Mon, 5 May 2008 18:58:50 -0700
Message-ID: <20080505185850.789d870a.akpm@linux-foundation.org>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36299 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757000AbYEFB7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 21:59:40 -0400
In-Reply-To: <200805050342.m453gktl029817@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 May 2008 23:42:46 -0400 Ulrich Drepper <drepper@redhat.com> wrote:

> +static const struct flags_rmap sock_file_flags_remap[] = {
> +	{ SOCK_CLOEXEC, O_CLOEXEC },
> +};
> +
>  asmlinkage long sys_socket(int family, int type, int protocol)
>  {
>  	int retval;
>  	struct socket *sock;
> +	int fflags;
> +
> +	type = flags_remap(sock_file_flags_remap,
> +			   ARRAY_SIZE(sock_file_flags_remap),
> +			   type, &fflags);

oh, so that's what it does.

afaict we only ever remap one or two flags.  Would it not be more efficient
to do that inline?  Something along the lines of:

	type = flag_remap(type, &fflags, SOCK_whatever, O_whatever);
	type = flag_remap(type, &fflags, SOCK_whatever2, O_whatever2);

?

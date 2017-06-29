From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] sctp: Add peeloff-flags socket option
Date: Thu, 29 Jun 2017 23:56:21 +0100
Message-ID: <20170629225621.GN10672@ZenIV.linux.org.uk>
References: <20170629181340.12423-1-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andreas Steinmetz <ast@domdv.de>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:41342 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751784AbdF2W43 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 18:56:29 -0400
Content-Disposition: inline
In-Reply-To: <20170629181340.12423-1-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 02:13:40PM -0400, Neil Horman wrote:
> diff --git a/fs/file.c b/fs/file.c
> index 1c2972e..a4521da 100644
> --- a/fs/file.c
> +++ b/fs/file.c
> @@ -807,6 +807,7 @@ void set_close_on_exec(unsigned int fd, int flag)
>  		__clear_close_on_exec(fd, fdt);
>  	spin_unlock(&files->file_lock);
>  }
> +EXPORT_SYMBOL(set_close_on_exec);

Huh?

> +	set_close_on_exec(peeloff->sd, !!(flags & SOCK_CLOEXEC));

Why hadn't you set it when that descriptor had been allocated?
That
        retval = get_unused_fd_flags(0);
could just pass O_CLOEXEC and you'd get it set from the very
beginning...

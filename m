From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [net PATCH v1 2/2] net: netprio: fd passed in SCM_RIGHTS
 datagram not set correctly
Date: Tue, 14 Aug 2012 03:31:28 +0100
Message-ID: <20120814023128.GG23464@ZenIV.linux.org.uk>
References: <20120814013939.3144.13167.stgit@jf-dev1-dcblab>
 <20120814013944.3144.53854.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, joe@perches.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120814013944.3144.53854.stgit@jf-dev1-dcblab>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13, 2012 at 06:39:45PM -0700, John Fastabend wrote:
>  		/* Bump the usage count and install the file. */
>  		get_file(fp[i]);
>  		fd_install(new_fd, fp[i]);
> +		sock = sock_from_file(fp[i], &err);
> +		if (sock)
> +			sock->sk->sk_cgrp_prioidx = prioidx;

Better to do that before fd_install() exposes the sucker; it's not
a serious issue, but it's more obviously correct that way.

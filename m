From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 09/15] net: bus: Add garbage collector for
 AF_BUS sockets.
Date: Mon, 2 Jul 2012 18:44:23 +0100
Message-ID: <1341251063.2590.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
	 <1340988354-26981-10-git-send-email-vincent.sanders@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>
To: Vincent Sanders <vincent.sanders@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-10-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-29 at 17:45 +0100, Vincent Sanders wrote:
> From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> 
> This patch adds a garbage collector for AF_BUS sockets.
[...]
> +struct sock *bus_get_socket(struct file *filp)
> +{
> +	struct sock *u_sock = NULL;
> +	struct inode *inode = filp->f_path.dentry->d_inode;
> +
> +	/*
> +	 *	Socket ?
> +	 */
> +	if (S_ISSOCK(inode->i_mode) && !(filp->f_mode & FMODE_PATH)) {
> +		struct socket *sock = SOCKET_I(inode);
> +		struct sock *s = sock->sk;
> +
> +		/*
> +		 *	PF_BUS ?
> +		 */
> +		if (s && sock->ops && sock->ops->family == PF_BUS)
> +			u_sock = s;
> +	}
> +	return u_sock;
> +}
[...]

What about references cycles involving both AF_BUS and AF_UNIX sockets?
I think you must either specifically prevent passing AF_UNIX sockets
through AF_BUS sockets, or make a single garbage collector handle them
both.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

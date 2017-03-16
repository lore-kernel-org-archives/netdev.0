From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 5/5] epoll: Add busy poll support to epoll with
 socket fds.
Date: Thu, 16 Mar 2017 15:11:44 -0700
Message-ID: <1489702304.28631.251.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
         <20170316183302.15806.2645.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316183302.15806.2645.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-16 at 11:33 -0700, Alexander Duyck wrote:
> From: Sridhar Samudrala <sridhar.samudrala@intel.com>

> +/*
> + * If busy polling is on and the file is a socket, return a pointer to
> + * struct sock
> + */
> +static inline struct sock *ep_sk_from_file(struct file *file)
> +{
> +	struct inode *inode = file_inode(file);
> +
> +	if (!S_ISSOCK(inode->i_mode))
> +		return NULL;
> +
> +	return ((struct socket *)file->private_data)->sk;
> +}

I believe a more standard way is to use sock_from_file()

(This does not have to fetch a cache line to read i_mode ))

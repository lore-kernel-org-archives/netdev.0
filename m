From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: 2.5.70-bk+ broken networking
Date: Thu, 5 Jun 2003 00:32:08 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030605033208.GK24515@conectiva.com.br>
References: <20030604184341.A10256@beaverton.ibm.com> <Mutt.LNX.4.44.0306051325110.335-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick Mansfield <patmans@us.ibm.com>, Andrew Morton <akpm@digeo.com>,
   Stephen Hemminger <shemminger@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
Content-Disposition: inline
In-Reply-To: <Mutt.LNX.4.44.0306051325110.335-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For the curious, it was introduced in changeset 1.1259.9.18

- Arnaldo

Em Thu, Jun 05, 2003 at 01:25:58PM +1000, James Morris escreveu:
> On Wed, 4 Jun 2003, Patrick Mansfield wrote:
> 
> > [root@elm3b79 root]# ifup eth0
> > sender address length == 0
> 
> This is a bug introduced by a coding style cleanup, fix below.
> 
> 
> - James
> -- 
> James Morris
> <jmorris@intercode.com.au>
> 
> --- bk.pending/net/core/iovec.c	2003-06-05 11:12:59.000000000 +1000
> +++ bk.w1/net/core/iovec.c	2003-06-05 13:30:06.000000000 +1000
> @@ -47,10 +47,10 @@ int verify_iovec(struct msghdr *m, struc
>  						  address);
>  			if (err < 0)
>  				return err;
> -			m->msg_name = address;
> -		} else
> -			m->msg_name = NULL;
> -	}
> +		}
> +		m->msg_name = address;
> +	} else
> +		m->msg_name = NULL;
>  
>  	size = m->msg_iovlen * sizeof(struct iovec);
>  	if (copy_from_user(iov, m->msg_iov, size))
> 

From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.5.70-bk+ broken networking
Date: Thu, 5 Jun 2003 09:55:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030605095512.022ea3be.shemminger@osdl.org>
References: <20030604184341.A10256@beaverton.ibm.com>
	<Mutt.LNX.4.44.0306051325110.335-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: patmans@us.ibm.com, akpm@digeo.com, jgarzik@pobox.com, davem@redhat.com,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org, hch@infradead.org
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0306051325110.335-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 Jun 2003 13:25:58 +1000 (EST)
James Morris <jmorris@intercode.com.au> wrote:

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

Thanks, this works for me.  I will see if it fixes the other gnome mystery as well.

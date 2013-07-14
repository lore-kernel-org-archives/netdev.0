From: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch -stable] svcrdma: underflow issue in decode_write_list()
Date: Sun, 14 Jul 2013 22:40:37 +0300
Message-ID: <CA+_b7D+2O2E0S4vQY37SZcK3VTPUdd1cP8y9NuZM-HWwP3HNGw@mail.gmail.com>
References: <20130712063903.GB29320@longonot.mountain>
	<51DFBD49.7000205@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wharms-fPG8STNUNVg@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51DFBD49.7000205-fPG8STNUNVg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 7/12/13, walter harms <wharms-fPG8STNUNVg@public.gmane.org> wrote:

> i am struggling to understand what is actually checked here.
> Perhaps this improves the readability a bit
>  if ( nchunks < 0 ||
>        sizeof(struct rpcrdma_write_chunk) * nchunks > (SIZE_MAX - start) ||

That doesn't work.

This is one of the few times I get to use algebra in real life.  Yay!
The problem is you have to
have the nchunks by itself and the trusted bits on the other side.  So
the multiply becomes a
divide.

There are lots of these checks in the kernel.  It's idiomatic.

regards,
dan carpenter
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 14546] New: Off-by-two stack buffer overflow in function rpc_uaddr2sockaddr() of net/sunrpc/addr.c
Date: Thu, 12 Nov 2009 16:56:47 +1100
Message-ID: <19195.41887.250696.801873@notabene.brown>
References: <bug-14546-10286@http.bugzilla.kernel.org/>
	<20091110152908.7558a471.akpm@linux-foundation.org>
	<967DC2CE-588D-4207-BF2D-59727454DC2E@oracle.com>
	<2031D0B0-56C9-406E-B5CF-EE050E2CB437@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Fabio Olive Leite <fabio.olive-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, argp-YZAGAMbGdGKGw+nKnLezzg@public.gmane.org,
	bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	Linux Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux NFS Mailing list <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: message from Chuck Lever on Wednesday November 11
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday November 11, chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org wrote:
> On 2009-11-11 Fabio Olive Leite wrote:
> > On 2009-11-11 Patroklos Argyroudis wrote:
> >> There is no need to increase the size of the buffer since the new
> >> check (if (uaddr_len > sizeof(buf) - 2)) will terminate the function
> >> in case the valid universal address is RPCBIND_MAXUADDRLEN bytes.
> > On a second note, why is '\n' needed there? You should only need  
> > '\0', as a '\n'
> 
> > at the end is not required by any of the string functions used to  
> > convert the
> > address. I believe you could go with buf[RPCBIND_MAXUADDRLEN+1] for  
> > the extra NUL only.
> 
> AFAICT, strict_strtoul() requires the '\n\0' termination.

	if ((*tail == '\0') ||
		((len == (size_t)(tail - cp) + 1) && (*tail == '\n'))) {
		*res = val;
		return 0;
	}


allows, not requires.  Though admittedly that code isn't as clear as
one might like:
        if (tail[0] == 0 || (tail[0] == '\n' && tail[1] == 0) {
                .....
        }

NeilBrown
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 13/13] sunrpc: use SKB fragment destructors to delay
 completion until page is released by network stack.
Date: Fri, 22 Jul 2011 14:39:16 -0400
Message-ID: <1311359956.13553.8.camel@lade.trondhjem.org>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
	 <1311340653-19336-13-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
To: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1311340653-19336-13-git-send-email-ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-22 at 14:17 +0100, Ian Campbell wrote: 
> This prevents an issue where an ACK is delayed, a retransmit is queued (either
> at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> wire. If this happens to an NFS WRITE RPC then the write() system call
> completes and the userspace process can continue, potentially modifying data
> referenced by the retransmission before the retransmission occurs.
> 
> Signed-off-by: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
> Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> [since v1:
>   Push down from NFS layer into RPM layer
> ]
> ---
>  include/linux/sunrpc/xdr.h  |    2 ++
>  include/linux/sunrpc/xprt.h |    5 ++++-
>  net/sunrpc/clnt.c           |   27 ++++++++++++++++++++++-----
>  net/sunrpc/svcsock.c        |    2 +-
>  net/sunrpc/xprt.c           |   13 +++++++++++++
>  net/sunrpc/xprtsock.c       |    2 +-
>  6 files changed, 43 insertions(+), 8 deletions(-)

This looks good to me. Thanks, Ian!

Acked-by: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

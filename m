From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH 02/12] selinux: tag avc cache alloc as non-critical
Date: Thu, 10 May 2012 10:25:51 -0400
Message-ID: <CACLa4punzEWjxQ79GF2o5h-up5A43oBuP-LEXGiA-kKQxcG1iQ@mail.gmail.com>
References: <1336658065-24851-1-git-send-email-mgorman@suse.de>
	<1336658065-24851-3-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1336658065-24851-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2012 at 9:54 AM, Mel Gorman <mgorman@suse.de> wrote:
> Failing to allocate a cache entry will only harm performance not
> correctness. =A0Do not consume valuable reserve pages for something
> like that.
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Eric Paris <eparis@redhat.com>

> ---
> =A0security/selinux/avc.c | =A0 =A02 +-
> =A01 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/security/selinux/avc.c b/security/selinux/avc.c
> index 8ee42b2..75c2977 100644
> --- a/security/selinux/avc.c
> +++ b/security/selinux/avc.c
> @@ -280,7 +280,7 @@ static struct avc_node *avc_alloc_node(void)
> =A0{
> =A0 =A0 =A0 =A0struct avc_node *node;
>
> - =A0 =A0 =A0 node =3D kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
> + =A0 =A0 =A0 node =3D kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GF=
P_NOMEMALLOC);
> =A0 =A0 =A0 =A0if (!node)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> --
> 1.7.9.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

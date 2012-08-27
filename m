From: Iulius Curt <icurt@ixiacom.com>
Subject: Re: [PATCH v2] libceph: Fix sparse warning
Date: Mon, 27 Aug 2012 15:20:52 +0300
Message-ID: <503B6624.5000408@ixiacom.com>
References: <1345724069-12405-1-git-send-email-icurt@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Iulius Curt <iulius.curt@gmail.com>, <davem@davemloft.net>,
	<ceph-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<dbaluta@ixiacom.com>
To: <sage@inktank.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <1345724069-12405-1-git-send-email-icurt@ixiacom.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/23/2012 03:14 PM, Iulius Curt wrote:
> From: Iulius Curt<iulius.curt@gmail.com>
>
> Make ceph_monc_do_poolop() static to remove the following sparse warning:
>   * net/ceph/mon_client.c:616:5: warning: symbol 'ceph_monc_do_poolop' was not
>     declared. Should it be static?
> Also drops the 'ceph_monc_' prefix, now being a private function.
>
> Signed-off-by: Iulius Curt<icurt@ixiacom.com>
> ---
> v1 --->  v2
>   * drop the 'ceph_monc_' prefix
> ---
>   net/ceph/mon_client.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/ceph/mon_client.c b/net/ceph/mon_client.c
> index 105d533..84ce495 100644
> --- a/net/ceph/mon_client.c
> +++ b/net/ceph/mon_client.c
> @@ -613,7 +613,7 @@ bad:
>   /*
>    * Do a synchronous pool op.
>    */
> -int ceph_monc_do_poolop(struct ceph_mon_client *monc, u32 op,
> +static int do_poolop(struct ceph_mon_client *monc, u32 op,
>   			u32 pool, u64 snapid,
>   			char *buf, int len)
>   {
> @@ -663,7 +663,7 @@ out:
>   int ceph_monc_create_snapid(struct ceph_mon_client *monc,
>   			    u32 pool, u64 *snapid)
>   {
> -	return ceph_monc_do_poolop(monc,  POOL_OP_CREATE_UNMANAGED_SNAP,
> +	return do_poolop(monc,  POOL_OP_CREATE_UNMANAGED_SNAP,
>   				   pool, 0, (char *)snapid, sizeof(*snapid));
>
>   }
> @@ -672,7 +672,7 @@ EXPORT_SYMBOL(ceph_monc_create_snapid);
>   int ceph_monc_delete_snapid(struct ceph_mon_client *monc,
>   			    u32 pool, u64 snapid)
>   {
> -	return ceph_monc_do_poolop(monc,  POOL_OP_CREATE_UNMANAGED_SNAP,
> +	return do_poolop(monc,  POOL_OP_CREATE_UNMANAGED_SNAP,
>   				   pool, snapid, 0, 0);
>
>   }
> --
> 1.7.9.5
>
>
Hi Sage,

Can you, please, have a look.

Thanks,
Iulius


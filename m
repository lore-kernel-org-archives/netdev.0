From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH] RDS: verify the underlying transport exists before
 creating a connection
Date: Fri, 4 Sep 2015 10:32:14 -0700
Message-ID: <55E9D59E.4080103@oracle.com>
References: <1441385019-27019-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>, chien.yen@oracle.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441385019-27019-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sasha,

On 9/4/2015 9:43 AM, Sasha Levin wrote:
> There was no verification that an underlying transport exists when creating
> a connection, this would cause dereferencing a NULL ptr.
>
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   net/rds/connection.c |    6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/net/rds/connection.c b/net/rds/connection.c
> index a50e652..0218d81 100644
> --- a/net/rds/connection.c
> +++ b/net/rds/connection.c
> @@ -189,6 +189,12 @@ new_conn:
>   		}
>   	}
>
> +	if (trans == NULL) {
> +		kmem_cache_free(rds_conn_slab, conn);
> +		conn = ERR_PTR(-ENODEV);
> +		goto out;
> +	}
> +

Did you see the NULL oops in any tests ? The reason
am asking this because callers of '__rds_conn_create()'
are not passing the trans as null so that leaves with
only the loopback case. In that case as well,
rds_loop_transport is never going to be null.

The check is good but am curious whether we have a
case which will hit this scenario.

Regards,
Santosh

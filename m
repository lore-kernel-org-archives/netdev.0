From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net] rds: Fix non-atomic operation on shared flag variable
Date: Tue, 5 Sep 2017 09:33:04 -0700
Message-ID: <6a4e095f-20f1-53af-a2eb-047866c1695d@oracle.com>
References: <20170905154201.30198-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org, knut.omang@oracle.com,
        wei.lin.guay@oracle.com
To: =?UTF-8?Q?H=c3=a5kon_Bugge?= <Haakon.Bugge@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40346 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbdIEQcb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 12:32:31 -0400
In-Reply-To: <20170905154201.30198-1-Haakon.Bugge@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/2017 8:42 AM, Håkon Bugge wrote:
> The bits in m_flags in struct rds_message are used for a plurality of
> reasons, and from different contexts. To avoid any missing updates to
> m_flags, use the atomic set_bit() instead of the non-atomic equivalent.
> 
> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
> Reviewed-by: Knut Omang <knut.omang@oracle.com>
> Reviewed-by: Wei Lin Guay <wei.lin.guay@oracle.com>
> ---
>   net/rds/send.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/rds/send.c b/net/rds/send.c
> index 41b9f0f..058a407 100644
> --- a/net/rds/send.c
> +++ b/net/rds/send.c
> @@ -273,7 +273,7 @@ int rds_send_xmit(struct rds_conn_path *cp)
>   			len = ntohl(rm->m_inc.i_hdr.h_len);
>   			if (cp->cp_unacked_packets == 0 ||
>   			    cp->cp_unacked_bytes < len) {
> -				__set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
> +				set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
>   
>   				cp->cp_unacked_packets =
>   					rds_sysctl_max_unacked_packets;
> @@ -829,7 +829,7 @@ static int rds_send_queue_rm(struct rds_sock *rs, struct rds_connection *conn,
>   		 * throughput hits a certain threshold.
>   		 */
>   		if (rs->rs_snd_bytes >= rds_sk_sndbuf(rs) / 2)
> -			__set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
> +			set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
>   
>   		list_add_tail(&rm->m_sock_item, &rs->rs_send_queue);
>   		set_bit(RDS_MSG_ON_SOCK, &rm->m_flags);
> 
Indeed, these couple of instances remained for the m_flags.
Patch looks good. Thanks !!

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH v4 1/2] RDS: memory allocated must be align to 8
Date: Fri, 8 Apr 2016 12:44:39 -0700
Message-ID: <57080A27.8050509@oracle.com>
References: <1460030256-16791-1-git-send-email-shamir.rabinovitch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32047 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbcDHTpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 15:45:11 -0400
In-Reply-To: <1460030256-16791-1-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/7/2016 4:57 AM, Shamir Rabinovitch wrote:
> Fix issue in 'rds_ib_cong_recv' when accessing unaligned memory
> allocated by 'rds_page_remainder_alloc' using uint64_t pointer.
>
Sorry I still didn't follow this change still. What exactly is the
problem.

> Signed-off-by: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
> ---
>   net/rds/page.c |    4 ++--
>   1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/rds/page.c b/net/rds/page.c
> index 616f21f..e2b5a58 100644
> --- a/net/rds/page.c
> +++ b/net/rds/page.c
> @@ -135,8 +135,8 @@ int rds_page_remainder_alloc(struct scatterlist *scat, unsigned long bytes,
>   			if (rem->r_offset != 0)
>   				rds_stats_inc(s_page_remainder_hit);
>
> -			rem->r_offset += bytes;
> -			if (rem->r_offset == PAGE_SIZE) {
> +			rem->r_offset += ALIGN(bytes, 8);
> +			if (rem->r_offset >= PAGE_SIZE) {
>   				__free_page(rem->r_page);
>   				rem->r_page = NULL;
>   			}
>

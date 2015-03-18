From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 3/4] IB/mlx4: Saturate RoCE port PMA counters in case
 of overflow
Date: Wed, 18 Mar 2015 17:36:31 +0300
Message-ID: <55098D6F.7040008@cogentembedded.com>
References: <1426688693-18980-1-git-send-email-ogerlitz@mellanox.com> <1426688693-18980-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:36546 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755077AbbCROgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 10:36:35 -0400
Received: by lbblx11 with SMTP id lx11so8928987lbb.3
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 07:36:33 -0700 (PDT)
In-Reply-To: <1426688693-18980-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/18/2015 5:24 PM, Or Gerlitz wrote:

> From: Majd Dibbiny <majd@mellanox.com>

> For RoCE ports, we set the u32 PMA values based on u64 HCA counters. In case of
> overflow, according to the IB spec, we have to saturate a counter to its
> max value, do that.

> Fixes: c37791349cc7 ('IB/mlx4: Support PMA counters for IBoE')
> Signed-off-by: Majd Dibbiny <majd@mellanox.com>
> Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>   drivers/infiniband/hw/mlx4/mad.c |   23 +++++++++++++++++++----
>   1 files changed, 19 insertions(+), 4 deletions(-)

> diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
> index c761971..40850f1 100644
> --- a/drivers/infiniband/hw/mlx4/mad.c
> +++ b/drivers/infiniband/hw/mlx4/mad.c
> @@ -64,6 +64,17 @@ enum {
>   #define GUID_TBL_BLK_NUM_ENTRIES 8
>   #define GUID_TBL_BLK_SIZE (GUID_TBL_ENTRY_SIZE * GUID_TBL_BLK_NUM_ENTRIES)
>
> +#define MAX_BE32 0xffffffffULL
> +#define MAX_BE16 0xffffUL

    Aren't U{16|32}_MAX from <linux/kernel.h> good enough?
    And I'm not seeing wheer MAX_BE16 is used...

[...]

WBR, Sergei

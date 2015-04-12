From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 09/11] net/mlx5: Ethernet Datapath files
Date: Sun, 12 Apr 2015 14:33:04 +0300
Message-ID: <CALzJLG-wmrc3FmtE2PrD4r3w+7em0WCb3YmRD1J=nT2=VvHfFg@mail.gmail.com>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
	<1428504685-8945-10-git-send-email-amirv@mellanox.com>
	<5525DD72.9040906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36673 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbbDLLdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 07:33:05 -0400
Received: by qku63 with SMTP id 63so122257785qku.3
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 04:33:04 -0700 (PDT)
In-Reply-To: <5525DD72.9040906@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 9, 2015 at 5:01 AM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> On 04/08/2015 07:51 AM, Amir Vadai wrote:
>>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 249 +++++++++++++++
>>   drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 350
>> ++++++++++++++++++++++
>>   drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 107 +++++++
>>   3 files changed, 706 insertions(+)
>>   create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>>   create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
>>   create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
>>
>
> <snip>
>
>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
>> b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
>> new file mode 100644
>> index 0000000..088bc42
>> --- /dev/null
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
>> @@ -0,0 +1,107 @@
>> +/*
>> + * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
>> + *
>> + * This software is available to you under a choice of one of two
>> + * licenses.  You may choose to be licensed under the terms of the GNU
>> + * General Public License (GPL) Version 2, available from the file
>> + * COPYING in the main directory of this source tree, or the
>> + * OpenIB.org BSD license below:
>> + *
>> + *     Redistribution and use in source and binary forms, with or
>> + *     without modification, are permitted provided that the following
>> + *     conditions are met:
>> + *
>> + *      - Redistributions of source code must retain the above
>> + *        copyright notice, this list of conditions and the following
>> + *        disclaimer.
>> + *
>> + *      - Redistributions in binary form must reproduce the above
>> + *        copyright notice, this list of conditions and the following
>> + *        disclaimer in the documentation and/or other materials
>> + *        provided with the distribution.
>> + *
>> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
>> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
>> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
>> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
>> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
>> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
>> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
>> + * SOFTWARE.
>> + */
>> +
>> +#include "en.h"
>> +
>> +struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
>> +{
>> +       struct mlx5_cqwq *wq = &cq->wq;
>> +       u32 ci = mlx5_cqwq_get_ci(wq);
>> +       struct mlx5_cqe64 *cqe = mlx5_cqwq_get_wqe(wq, ci);
>> +       int cqe_ownership_bit = cqe->op_own & MLX5_CQE_OWNER_MASK;
>> +       int sw_ownership_val = mlx5_cqwq_get_wrap_cnt(wq) & 1;
>> +
>> +       if (cqe_ownership_bit != sw_ownership_val)
>> +               return NULL;
>> +
>> +       mlx5_cqwq_pop(wq);
>> +
>> +       /* ensure cqe content is read after cqe ownership bit */
>> +       rmb();
>> +
>> +       return cqe;
>> +}
>> +
>
>
> I'm pretty sure this rmb can be a dma_rmb.
Thanks, we will change it in V1

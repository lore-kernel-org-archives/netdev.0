From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][next] net: hinic: fix comparison of a uint16_t type
 with -1
Date: Thu, 24 Aug 2017 14:32:30 -0700 (PDT)
Message-ID: <20170824.143230.1441873385968459116.davem@davemloft.net>
References: <20170823153936.22857-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aviad.krawczyk@huawei.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170823153936.22857-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed, 23 Aug 2017 16:39:36 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The comparison of hw_ioctxt.rx_buf_sz_idx == -1 is always false because
> rx_buf_sz_idx is a uint16_t. Fix this by explicitly casting -1 to uint16_t.
> 
> Detected by CoverityScan, CID#1454559 ("Operands don't affect result")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
> index 09dec6de8dd5..71e26070fb7f 100644
> --- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
> +++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
> @@ -352,7 +352,7 @@ static int set_hw_ioctxt(struct hinic_hwdev *hwdev, unsigned int rq_depth,
>  		}
>  	}
>  
> -	if (hw_ioctxt.rx_buf_sz_idx == -1)
> +	if (hw_ioctxt.rx_buf_sz_idx == (uint16_t)-1)
>  		return -EINVAL;
>  
>  	hw_ioctxt.sq_depth  = ilog2(sq_depth);

This is really silly.

The code in question is trying to convert a size (HINIC_RX_BUF_SZ)
into a table index, using a loop.

It should just compute this at compile time and do away with this
overly confusing code.

Even a switch statement would be much better and the compiler
would optimize the whole away into a single assignment in
the generated code.

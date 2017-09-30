From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH] net: hns3: Fix an error handling path in
 'hclge_rss_init_hw()'
Date: Sat, 30 Sep 2017 14:10:31 +0800
Message-ID: <ab4512d9-ba6c-d57a-55b0-8d4a32672d6e@huawei.com>
References: <20170930053434.4558-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
        <davem@davemloft.net>, <lipeng321@huawei.com>,
        <colin.king@canonical.com>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170930053434.4558-1-christophe.jaillet@wanadoo.fr>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Christophe

On 2017/9/30 13:34, Christophe JAILLET wrote:
> If this sanity check fails, we must free 'rss_indir'. Otherwise there is a
> memory leak.
> 'goto err' as done in the other error handling paths to fix it.

Thanks for fixing.

> 
> Fixes: 46a3df9f9718 ("net: hns3: Fix for setting rss_size incorrectly")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
>  drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
> index e0685e630afe..c1cdbfd83bdb 100644
> --- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
> +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
> @@ -2652,7 +2652,8 @@ static int hclge_rss_init_hw(struct hclge_dev *hdev)
>  		dev_err(&hdev->pdev->dev,
>  			"Configure rss tc size failed, invalid TC_SIZE = %d\n",
>  			rss_size);
> -		return -EINVAL;
> +		ret = -EINVAL;
> +		goto err;
>  	}
>  
>  	roundup_size = roundup_pow_of_two(rss_size);
> 

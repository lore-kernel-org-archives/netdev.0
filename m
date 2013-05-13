From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] bna: add missing iounmap() on error in bnad_init()
Date: Mon, 13 May 2013 18:01:45 +0400
Message-ID: <5190F249.9020309@cogentembedded.com>
References: <CAPgLHd8G816BcF7U6eG320w=k9Zv-yVYjt4wreyU67eSdVRERg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, huangj@brocade.com, davem@davemloft.net,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:51028 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab3EMOBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 10:01:51 -0400
Received: by mail-lb0-f172.google.com with SMTP id y6so6416647lbh.3
        for <netdev@vger.kernel.org>; Mon, 13 May 2013 07:01:49 -0700 (PDT)
In-Reply-To: <CAPgLHd8G816BcF7U6eG320w=k9Zv-yVYjt4wreyU67eSdVRERg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 13-05-2013 11:26, Wei Yongjun wrote:

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

> Add the missing iounmap() before return from bnad_init()
> in the error handling case.
> Introduced by commit 01b54b1451853593739816a392485c4e2bee7dda
> (bna: tx rx cleanup fix).

> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>   drivers/net/ethernet/brocade/bna/bnad.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
> index ce4a030..59da9eb 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad.c
> @@ -3237,8 +3237,10 @@ bnad_init(struct bnad *bnad,
>   	sprintf(bnad->wq_name, "%s_wq_%d", BNAD_NAME, bnad->id);
>   	bnad->work_q = create_singlethread_workqueue(bnad->wq_name);
>

    Empty line not needed here -- maybe it's time to delete it?

> -	if (!bnad->work_q)
> +	if (!bnad->work_q) {
> +		iounmap(bnad->bar0);
>   		return -ENOMEM;
> +	}
>
>   	return 0;
>   }

WBR, Sergei

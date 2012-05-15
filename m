From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 1/8] net/mlx4: Address build warnings on set
 but not used variables
Date: Tue, 15 May 2012 08:52:06 +0300
Message-ID: <4FB1EF06.6070909@mellanox.com>
References: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com> <1337025853-26685-2-git-send-email-ogerlitz@mellanox.com> <20120515.000754.1011080018257342361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roland@kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:39259 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751912Ab2EOFwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 01:52:13 -0400
In-Reply-To: <20120515.000754.1011080018257342361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/15/2012 7:07 AM, David Miller wrote:
>
>> -		err = mlx4_qp_detach_common(dev,&qp, rgid->gid, rgid->prot,
>> +		(void) mlx4_qp_detach_common(dev,&qp, rgid->gid, rgid->prot,
>>   					    rgid->steer);
>
> You must update the indentation of all the lines comprising of the function call when you change the indentation of it's initial line.

Just want to make sure I understood right what has to be done here, e.g 
in this case its needs to be
like this?

> @@ -2604,13 +2604,12 @@ static void detach_qp(struct mlx4_dev *dev, 
> int slave, struct res_qp *rqp)
>  {
>         struct res_gid *rgid;
>         struct res_gid *tmp;
> -       int err;
>         struct mlx4_qp qp; /* dummy for calling attach/detach */
>
>         list_for_each_entry_safe(rgid, tmp, &rqp->mcg_list, list) {
>                 qp.qpn = rqp->local_qpn;
> -               err = mlx4_qp_detach_common(dev, &qp, rgid->gid, 
> rgid->prot,
> -                                           rgid->steer);
> +               (void) mlx4_qp_detach_common(dev, &qp, rgid->gid, 
> rgid->prot,
> +                                                   rgid->steer);
>                 list_del(&rgid->list);
>                 kfree(rgid);
>         }

Or.

From: Moni Shoua <monis@mellanox.com>
Subject: Re: [PATCH net-next 2/3] IB/mlx4: Always use the correct port for
 mirrored multicast attachments
Date: Thu, 5 Feb 2015 17:18:06 +0200
Message-ID: <CAG9sBKMM+BGF49yMJDyzkP7SzgOknu52k5Tc1rDf-2AkpnAaog@mail.gmail.com>
References: <1423144366-11814-1-git-send-email-ogerlitz@mellanox.com>
	<1423144366-11814-3-git-send-email-ogerlitz@mellanox.com>
	<54D3787C.3030603@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:49796 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757514AbbBEPSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 10:18:08 -0500
Received: by mail-qa0-f44.google.com with SMTP id w8so6235791qac.3
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 07:18:06 -0800 (PST)
In-Reply-To: <54D3787C.3030603@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>                         goto err_create_flow;
>>                 i++;
>>                 if (is_bonded) {
>> +                       /* Application always sees one port so the mirror
>> rule
>> +                        * must be on port #2
>> +                        */
>
>
>    Unrelated change?
>
I think that it is somewhat related since it explains why the fix,
though seems to be relevant also here is actually not
>>                         flow_attr->port = 2;
>>                         err = __mlx4_ib_create_flow(qp, flow_attr,
>>                                                     domain, type[j],
>> @@ -1279,14 +1282,15 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp,
>> union ib_gid *gid, u16 lid)
>>
>>         err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw,
>> mqp->port,
>>                                     !!(mqp->flags &
>> -
>> MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
>> +                                   MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
>
>
>    This change is both unrelated and unneeded.
I agree.
>
>>                                     prot, &reg_id.id);
>>         if (err)
>>                 goto err_malloc;
>>
>>         reg_id.mirror = 0;
>>         if (mlx4_is_bonded(dev)) {
>> -               err = mlx4_multicast_attach(mdev->dev, &mqp->mqp,
>> gid->raw, 2,
>> +               err = mlx4_multicast_attach(mdev->dev, &mqp->mqp,
>> gid->raw,
>> +                                           (mqp->port == 1) ? 2 : 1,
>
>
>    I doubt that these parens are needed.
You are right if all you care about is the machine code. For
readability I like the parens.
>
> WBR, Sergei
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

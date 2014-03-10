From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 1/7] mlx4: Adjust QP1 multiplexing for RoCE/SRIOV
Date: Mon, 10 Mar 2014 22:31:52 +0200
Message-ID: <CAJZOPZK=0e2j+qTp_+oL0oE5ORNO71f7vvFU8WW7uEzGhrzvXw@mail.gmail.com>
References: <1394376844-12812-1-git-send-email-ogerlitz@mellanox.com>
	<1394376844-12812-2-git-send-email-ogerlitz@mellanox.com>
	<20140310.155015.1679111216670234389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roland Dreier <roland@kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:50110 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbaCJUbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:31:53 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so7548487pdj.4
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 13:31:52 -0700 (PDT)
In-Reply-To: <20140310.155015.1679111216670234389.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 10, 2014 at 9:50 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Sun,  9 Mar 2014 16:53:58 +0200
>
>> @@ -509,6 +510,10 @@ int mlx4_ib_send_to_slave(struct mlx4_ib_dev *dev, int slave, u8 port,
>>        * The driver will set the force loopback bit in post_send */
>>       memset(&attr, 0, sizeof attr);
>>       attr.port_num = port;
>> +     if (is_eth) {
>> +             mlx4_get_roce_gid_from_slave(dev->dev, port, slave, attr.grh.dgid.raw);
>> +             attr.ah_flags = IB_AH_GRH;
>> +     }
>>       ah = ib_create_ah(tun_ctx->pd, &attr);
>>       if (IS_ERR(ah))
>>               return -ENOMEM;
>
> Either the error returned from mlx4_get_roce_gid_from_slave() doesn't matter...
>
>> +                     err = mlx4_get_roce_gid_from_slave(to_mdev(ib_dev)->dev,
>> +                                                        be32_to_cpu(ah->av.ib.port_pd) >> 24,
>> +                                                        ah->av.ib.gid_index, &sgid.raw[0]);
>> +                     if (err)
>> +                             return err;
>
> or it does.
>
> Please decide whether it does or not.  If it does, make all call sites check the return
> value.  If it does not, remove the return value and make the function return void.

Sure, I'll take a look and respin V1

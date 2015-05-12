From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V3 08/11] net/mlx5_core: Set/Query port MTU commands
Date: Tue, 12 May 2015 11:19:46 +0300
Message-ID: <CAPcc5Pje2c-bEgm+VCXCf6aXp7yV94UKUOw1e0HNO1WTUx0=dw@mail.gmail.com>
References: <1431250746-11941-1-git-send-email-amirv@mellanox.com>
	<1431250746-11941-9-git-send-email-amirv@mellanox.com>
	<554F880B.8060203@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:35523 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbbELITr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 04:19:47 -0400
Received: by labbd9 with SMTP id bd9so111462222lab.2
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 01:19:46 -0700 (PDT)
In-Reply-To: <554F880B.8060203@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2015 at 7:32 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 5/10/2015 12:39 PM, Amir Vadai wrote:
>
>> From: Saeed Mahameed <saeedm@mellanox.com>
>
>
>> Introduce set/Query low level functions to access MTU in hardware. To be
>> used by the netdev.
>
>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx5/core/port.c | 56
>> ++++++++++++++++++++++++++
>>   include/linux/mlx5/driver.h                    |  4 ++
>>   2 files changed, 60 insertions(+)
>
>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c
>> b/drivers/net/ethernet/mellanox/mlx5/core/port.c
>> index 742a6fb..e56a0b6 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
>> @@ -211,3 +211,59 @@ int mlx5_query_port_status(struct mlx5_core_dev *dev,
>> u8 *status)
>
> [...]
>>
>> +int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu)
>> +{
>> +       u32 in[MLX5_ST_SZ_DW(pmtu_reg)];
>> +       u32 out[MLX5_ST_SZ_DW(pmtu_reg)];
>> +       int err;
>> +
>> +       memset(in, 0, sizeof(in));
>> +
>> +       MLX5_SET(pmtu_reg, in, admin_mtu, mtu);
>> +       MLX5_SET(pmtu_reg, in, local_port, 1);
>> +
>> +       err = mlx5_core_access_reg(dev, in, sizeof(in), out,
>> +                                  sizeof(out), MLX5_REG_PMTU, 0, 1);
>> +
>> +       return err;
>
>
>    Why not just return directly?
Will be fixed in V4

Thanks,
Amir

>
> [...]
>
> WBR, Sergei
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

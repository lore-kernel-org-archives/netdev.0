From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 07/11] net/mlx5_core: Implement get/set port status
Date: Wed, 8 Apr 2015 21:38:31 +0300
Message-ID: <CAPcc5PjbS_kwCW=Fj-7LAHe4ELUWfeuRTAkDBQK8uy-F=9UNPQ@mail.gmail.com>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
	<1428504685-8945-8-git-send-email-amirv@mellanox.com>
	<552572DD.6030105@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:33888 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400AbbDHSid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 14:38:33 -0400
Received: by lbcga7 with SMTP id ga7so24228518lbc.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 11:38:31 -0700 (PDT)
In-Reply-To: <552572DD.6030105@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 8, 2015 at 9:26 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
Hi,

>
>
> On 04/08/2015 05:51 PM, Amir Vadai wrote:
>
>> From: Rana Shahout <ranas@mellanox.com>
>
>
>> Signed-off-by: Rana Shahout <ranas@mellanox.com>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx5/core/port.c | 34
>> ++++++++++++++++++++++++++
>>   include/linux/mlx5/driver.h                    |  8 ++++++
>>   2 files changed, 42 insertions(+)
>
>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c
>> b/drivers/net/ethernet/mellanox/mlx5/core/port.c
>> index 6e2d99c..7c394c0 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
>> @@ -179,3 +179,37 @@ int mlx5_set_port_proto(struct mlx5_core_dev *dev,
>> u32 proto_admin,
>>         return err;
>>   }
>>   EXPORT_SYMBOL_GPL(mlx5_set_port_proto);
>> +
>> +int mlx5_set_port_status(struct mlx5_core_dev *dev,
>> +                        enum mlx5_port_status status)
>> +{
>> +       u32 in[MLX5_ST_SZ_DW(paos_reg)];
>> +       u32 out[MLX5_ST_SZ_DW(paos_reg)];
>> +       int err;
>> +
>> +       memset(in, 0, sizeof(in));
>> +
>> +       MLX5_SET(paos_reg, in, admin_status, status);
>> +       MLX5_SET(paos_reg, in, ase, 1);
>> +
>> +       err = mlx5_core_access_reg(dev, in, sizeof(in), out,
>> +                                  sizeof(out), MLX5_REG_PAOS, 0, 1);
>> +       return err;
>
>
>    Why not just direct return of the function's result?
Right - will be fixed in V1.

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

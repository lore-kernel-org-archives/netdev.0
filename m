From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [net-next:master 1324/1341]
 drivers/net//ethernet/mellanox/mlxsw/spectrum_dpipe.c:323:9: error: too few
 arguments to function 'devlink_dpipe_table_register'
Date: Fri, 25 Aug 2017 12:59:02 +0300
Message-ID: <680a0c71-6e9c-7058-7451-9e4e529adc3b@mellanox.com>
References: <201708250827.irRihDoq%fengguang.wu@intel.com>
 <20170824.181124.1922755161454657026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org, jiri@mellanox.com
To: David Miller <davem@davemloft.net>, fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40053.outbound.protection.outlook.com ([40.107.4.53]:4640
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754537AbdHYKAn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 06:00:43 -0400
In-Reply-To: <20170824.181124.1922755161454657026.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/25/2017 04:11 AM, David Miller wrote:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Fri, 25 Aug 2017 08:03:28 +0800
> 
>> All errors (new ones prefixed by >>):
>>
>>    drivers/net//ethernet/mellanox/mlxsw/spectrum_dpipe.c: In function 'mlxsw_sp_dpipe_erif_table_init':
>>>> drivers/net//ethernet/mellanox/mlxsw/spectrum_dpipe.c:323:9: error: too few arguments to function 'devlink_dpipe_table_register'
>>      return devlink_dpipe_table_register(devlink,
>>             ^
>>    In file included from drivers/net//ethernet/mellanox/mlxsw/spectrum_dpipe.c:36:0:
>>    include/net/devlink.h:401:1: note: declared here
>>     devlink_dpipe_table_register(struct devlink *devlink,
>>     ^
>>    drivers/net//ethernet/mellanox/mlxsw/spectrum_dpipe.c:327:1: warning: control reaches end of non-void function [-Wreturn-type]
>>     }
>>     ^
> 
> I'll push the following fix into net-next for this:
> 
> ====================
> From 790c6056686cc4dd5b149b330bbd5ae208d4d721 Mon Sep 17 00:00:00 2001
> From: "David S. Miller" <davem@davemloft.net>
> Date: Thu, 24 Aug 2017 18:10:46 -0700
> Subject: [PATCH] devlink: Fix devlink_dpipe_table_register() stub signature.
> 
> One too many arguments compared to the non-stub version.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: ffd3cdccf214 ("devlink: Add support for dynamic table size")
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/net/devlink.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/include/net/devlink.h b/include/net/devlink.h
> index 047a0c54f652..aaf7178127a2 100644
> --- a/include/net/devlink.h
> +++ b/include/net/devlink.h
> @@ -402,8 +402,7 @@ static inline int
>  devlink_dpipe_table_register(struct devlink *devlink,
>  			     const char *table_name,
>  			     struct devlink_dpipe_table_ops *table_ops,
> -			     void *priv, u64 size,
> -			     bool counter_control_extern)
> +			     void *priv, bool counter_control_extern)
>  {
>  	return 0;
>  }
> 

Thank you, sorry for the mistake.

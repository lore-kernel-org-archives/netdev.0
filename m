From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net 2/2] mlxsw: spectrum_router: Correctly dump neighbour
 activity
Date: Fri, 11 Nov 2016 14:13:28 +0100
Message-ID: <20161111131328.GB1873@nanopsycho.orion>
References: <1478859642-2918-1-git-send-email-jiri@resnulli.us>
 <1478859642-2918-3-git-send-email-jiri@resnulli.us>
 <20161111125405.x56ipwlaoln4b4fe@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        arkadis@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36671 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932375AbcKKNNb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 08:13:31 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so7744398wma.3
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 05:13:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161111125405.x56ipwlaoln4b4fe@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Nov 11, 2016 at 01:54:05PM CET, idosch@idosch.org wrote:
>On Fri, Nov 11, 2016 at 11:20:42AM +0100, Jiri Pirko wrote:
>> From: Arkadi Sharshevsky <arkadis@mellanox.com>
>> 
>> During neighbour activity check the device's table is dumped by multiple
>> query requests. The query session should end when the response carries
>> less records than requested or when a given record is not full. Current
>> code only stops the dumping process if the number of returned records is
>> zero, which can result in infinite loop in case of activity.
>> 
>> Fix this by stopping the dumping process according to the above logic.
>> 
>> Fixes: c723c735fa6b ("mlxsw: spectrum_router: Periodically update the kernel's neigh table")
>> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 +++++++++++++++++++++-
>>  1 file changed, 21 insertions(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>> index 040737e..d437457 100644
>> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>> @@ -800,6 +800,26 @@ static void mlxsw_sp_router_neigh_rec_process(struct mlxsw_sp *mlxsw_sp,
>>  	}
>>  }
>>  
>> +static bool mlxsw_sp_router_rauhtd_is_full(char *rauhtd_pl)
>> +{
>> +	u8 num_rec, last_rec_index, num_entries;
>> +
>> +	num_rec = mlxsw_reg_rauhtd_num_rec_get(rauhtd_pl);
>> +	last_rec_index = num_rec - 1;
>> +
>> +	if (num_rec < MLXSW_REG_RAUHTD_REC_MAX_NUM)
>> +		return false;
>> +	if (mlxsw_reg_rauhtd_rec_type_get(rauhtd_pl, last_rec_index) ==
>> +	    MLXSW_REG_RAUHTD_TYPE_IPV6)
>> +		return true;
>> +
>> +	num_entries = mlxsw_reg_rauhtd_ipv4_rec_num_entries_get(rauhtd_pl,
>> +								last_rec_index);
>> +	if (++num_entries ==  MLXSW_REG_RAUHTD_IPV4_ENT_PER_REC)
>
>Jiri, I just noticed we have an extra space after the '=='. Can you
>please remove it in v2? Sorry for not spotting this earlier.


Will do.

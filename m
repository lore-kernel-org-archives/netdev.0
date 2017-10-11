From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC net-next 4/4] mlxsw: spectrum_router: Add extack message for
 RIF and VRF overflow
Date: Wed, 11 Oct 2017 09:07:20 -0600
Message-ID: <72ad213d-7074-e4ca-6799-94da01c38f8e@gmail.com>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
 <1507653665-20540-5-git-send-email-dsahern@gmail.com>
 <20171011141330.GC11653@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35907 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757595AbdJKPHS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 11:07:18 -0400
Received: by mail-pg0-f68.google.com with SMTP id k70so155936pgc.3
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 08:07:18 -0700 (PDT)
In-Reply-To: <20171011141330.GC11653@splinter>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/17 8:13 AM, Ido Schimmel wrote:
> On Tue, Oct 10, 2017 at 09:41:05AM -0700, David Ahern wrote:
>> Add extack argument down to mlxsw_sp_rif_create and mlxsw_sp_vr_create
>> to set an error message on RIF or VR overflow. Now an overflow of
>> either resource the use gets an informative message as opposed to
> 
> s/the/in/ ?

'use' is supposed to be 'user'


>> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>> index 7d53fdf2c0a8..ec4d313b9eca 100644
>> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>> @@ -731,14 +731,17 @@ static struct mlxsw_sp_fib *mlxsw_sp_vr_fib(const struct mlxsw_sp_vr *vr,
>>  }
>>  
>>  static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
>> -					      u32 tb_id)
>> +					      u32 tb_id,
>> +					      struct netlink_ext_ack *extack)
>>  {
>>  	struct mlxsw_sp_vr *vr;
>>  	int err;
>>  
>>  	vr = mlxsw_sp_vr_find_unused(mlxsw_sp);
>> -	if (!vr)
>> +	if (!vr) {
>> +		NL_SET_ERR_MSG(extack, "spectrum: Exceeded number of supported VRF");
> 
> Maybe:
> "spectrum: Exceeded number of supported VRF devices"

In this context the overflow is virtual routers in spectrum as opposed
to VRF devices in the kernel context. The existence of the VRF device
has no bearing until a port is enslaved to it.

How about:
 "spectrum: Exceeded number of supported virtual routers"

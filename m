From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 24/26] mlxsw: spectrum: Implement LAG port
 join/leave
Date: Wed, 02 Dec 2015 12:30:07 -0500 (EST)
Message-ID: <20151202.123007.603825526895856619.davem@davemloft.net>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
	<1448977744-17930-25-git-send-email-jiri@resnulli.us>
	<CAJ3xEMjzSHFo8YQZcd-nP0BeMhnSV=1kgtdkk_Wc80Tuk=GnKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964956AbbLBRaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 12:30:09 -0500
In-Reply-To: <CAJ3xEMjzSHFo8YQZcd-nP0BeMhnSV=1kgtdkk_Wc80Tuk=GnKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Wed, 2 Dec 2015 07:47:51 +0200

> On Tue, Dec 1, 2015 at 3:49 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Implement basic procedures for joining/leaving port to/from LAG. That
>> includes HW setup of collector, core LAG mapping setup.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 284 +++++++++++++++++++++++--
>>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  35 ++-
>>  2 files changed, 302 insertions(+), 17 deletions(-)
>>
>> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
>> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
> 
> [...]
> 
>> +static int mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
>> +                                  struct net_device *lag_dev)
>> +{
>> +       struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
>> +       struct mlxsw_sp_upper *lag;
>> +       u16 lag_id = mlxsw_sp_port->lag_id;
>> +       int err;
>> +
>> +       if (!mlxsw_sp_port->lagged)
>> +               return 0;
>> +       lag = mlxsw_sp_lag_get(mlxsw_sp, lag_id);
>> +       BUG_ON(lag->ref_count == 0);
> 
> is this a must to crash the system here? can't we do something less drastic?

Indeed, please use WARN_ON() and return an error or perform some other kind of
recovery operation.

BUG_ON() is bad and is only to ever be used when the kernel's
continued operation is absolutely impossible.

From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 24/26] mlxsw: spectrum: Implement LAG port
 join/leave
Date: Wed, 2 Dec 2015 08:57:00 +0100
Message-ID: <20151202075659.GC2355@nanopsycho.orion>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <1448977744-17930-25-git-send-email-jiri@resnulli.us>
 <CAJ3xEMjzSHFo8YQZcd-nP0BeMhnSV=1kgtdkk_Wc80Tuk=GnKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38327 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbbLBH5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 02:57:02 -0500
Received: by wmec201 with SMTP id c201so46194240wme.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 23:57:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjzSHFo8YQZcd-nP0BeMhnSV=1kgtdkk_Wc80Tuk=GnKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 02, 2015 at 06:47:51AM CET, gerlitz.or@gmail.com wrote:
>On Tue, Dec 1, 2015 at 3:49 PM, Jiri Pirko <jiri@resnulli.us> wrote:
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
>[...]
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
>is this a must to crash the system here? can't we do something less drastic?

This can never happen, unless something is seriously wrong with the
system (memory corruption, etc).

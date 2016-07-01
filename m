From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 11/42] mlxsw: spectrum: Add router interface
 struct
Date: Fri, 1 Jul 2016 21:37:13 +0300
Message-ID: <20160701183713.GB11348@colbert.idosch.org>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
 <1467381910-3445-12-git-send-email-jiri@resnulli.us>
 <90c0b9d3-6d54-c4f1-407f-0f93c12caf5d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <yotamg@mellanox.com>, <eladr@mellanox.com>,
	<nogahf@mellanox.com>, <ogerlitz@mellanox.com>,
	<sfeldma@gmail.com>, <roopa@cumulusnetworks.com>,
	<andy@greyhouse.net>, <tgraf@suug.ch>, <jhs@mojatatu.com>,
	<linville@tuxdriver.com>, <ivecera@redhat.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0054.outbound.protection.outlook.com ([104.47.2.54]:7328
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751128AbcGAWSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2016 18:18:55 -0400
Content-Disposition: inline
In-Reply-To: <90c0b9d3-6d54-c4f1-407f-0f93c12caf5d@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 01, 2016 at 07:16:23PM IDT, dsa@cumulusnetworks.com wrote:
>On 7/1/16 8:04 AM, Jiri Pirko wrote:
>> @@ -327,6 +333,19 @@ mlxsw_sp_port_vport_find_by_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
>>  	return NULL;
>>  }
>>
>> +static inline struct mlxsw_sp_rif *
>> +mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
>> +			 const struct net_device *dev)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < MLXSW_SP_RIF_MAX; i++)
>> +		if (mlxsw_sp->rifs[i] && mlxsw_sp->rifs[i]->dev == dev)
>> +			return mlxsw_sp->rifs[i];
>> +
>> +	return NULL;
>> +}
>> +
>
>Why not add the rif to mlxsw_sp_port which is the priv data for a mlxsw dev?

We create 'mlxsw_sp_port' for physical ports and vPorts (VLAN netdevs),
but not for master devices such as bridge and team, which can also be
assigned RIFs. The reason for this is that in most cases any bridge /
team setting eventually needs to be programmed to the device via each
slave 'mlxsw_sp_port'. You can see, for example, that in our netdev
notification block we simply propagate team/bond CHANGEUPPER to each
slave port.

Thanks for taking the time to review this!

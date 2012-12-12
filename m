From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Add support for destination
 MAC in steering rules
Date: Wed, 12 Dec 2012 12:07:43 +0200
Message-ID: <50C8576F.6090907@mellanox.com>
References: <1355227436-18383-1-git-send-email-amirv@mellanox.com> <1355227436-18383-3-git-send-email-amirv@mellanox.com> <50C75382.3040504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Yan Burman <yanb@mellanox.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:39504 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753733Ab2LLKJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 05:09:22 -0500
In-Reply-To: <50C75382.3040504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/2012 17:38, Brian Haley wrote:
> On 12/11/2012 07:03 AM, Amir Vadai wrote:
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
>> @@ -619,7 +619,13 @@ static int mlx4_en_validate_flow(struct net_device *dev,
>>   	if (cmd->fs.location >= MAX_NUM_OF_FS_RULES)
>>   		return -EINVAL;
>>
>> -	switch (cmd->fs.flow_type & ~FLOW_EXT) {
>> +	if (cmd->fs.flow_type & FLOW_MAC_EXT) {
>> +		/* dest mac mask must be ff:ff:ff:ff:ff:ff */
>> +		if (memcmp(cmd->fs.m_ext.h_dest, &full_mac, ETH_ALEN))
>> +			return -EINVAL;
>> +	}
>
> etherdevice.h has is_broadcast_ether_addr() and is_zero_ether_addr() if you want
> to get rid of full_mac and zero_mac in this function.
>
> -Brian
>

Right, will send a V1 with this fix.

Amir.

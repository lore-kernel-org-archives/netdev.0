From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 4/7] net/mlx4_en: Set carrier to off when a port
 is stopped
Date: Mon, 28 Jan 2013 14:07:19 +0200
Message-ID: <510669F7.2090705@mellanox.com>
References: <1358350935-3281-1-git-send-email-amirv@mellanox.com>  <1358350935-3281-5-git-send-email-amirv@mellanox.com> <1358352016.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:38469 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753090Ab3A1MGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 07:06:47 -0500
In-Reply-To: <1358352016.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/01/2013 18:00, Ben Hutchings wrote:
> On Wed, 2013-01-16 at 17:42 +0200, Amir Vadai wrote:
>> From: Eugenia Emantayev <eugenia@mellanox.com>
>>
>> Under heavy CPU load changing ring size/mtu/etc. could result in transmit
>> timeout, since stop-start port might take more than 10 sec. Set
>> netif_carrier_off to prevent tx queue transmit timeout.
>
> A spurious link change can restart L3 auto-configuration (DHCP, SLAAC,
> etc.)  netif_device_detach() also inhibits the watchdog and doesn't have
> that problem.
>
> Ben.
>

But after calling netif_device_detach(), device present bit is cleared 
and therefore won't be able to access the device. This means, that after 
'ifconfig down', won't be able to do 'ifconfig up'.

Amir


>> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    1 +
>>   1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> index 805e242..108c4cf 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> @@ -1212,6 +1212,7 @@ void mlx4_en_stop_port(struct net_device *dev)
>>
>>   	/* Synchronize with tx routine */
>>   	netif_tx_lock_bh(dev);
>> +	netif_carrier_off(dev);
>>   	netif_tx_stop_all_queues(dev);
>>   	netif_tx_unlock_bh(dev);
>>
>

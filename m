From: "Toshiharu Okada" <toshiharu-linux@dsn.okisemi.com>
Subject: Re: [PATCH] pch_gbe: Fix the issue which a driver locks when rx offload is set by ethtool
Date: Wed, 9 Feb 2011 11:04:11 +0900
Message-ID: <3F7E1C17407A45E3834BF70553CB294C@hacdom.okisemi.com>
References: <4D512A27.2030406@dsn.okisemi.com> <20110208.164030.242137610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tomoya-linux@dsn.okisemi.com>,
	<qi.wang@intel.com>, <yong.y.wang@intel.com>,
	<andrew.chih.howe.khor@intel.com>, <joel.clark@intel.com>,
	<kok.howg.ewe@intel.com>, <linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 08 Feb 2011 16:40:30 -0800 (PST)

>> @@ -531,12 +533,8 @@ void pch_gbe_reinit_locked(struct pch_gbe_adapter 
>> *adapter)
>>  {
>>  struct net_device *netdev = adapter->netdev;
>>
>> - rtnl_lock();
>> - if (netif_running(netdev)) {
>> - pch_gbe_down(adapter);
>> - pch_gbe_up(adapter);
>> - }
>> - rtnl_unlock();
>> + pch_gbe_down(adapter);
>> + pch_gbe_up(adapter);
>
>Are you sure you can just blindly delete the netif_running() check here?

Yes, sure.
pch_gbe_reinit_locked() is called after confirming of netif_running() except 
for pch_gbe_reset_task() function.
This netif_running() was redundant.

Best regards
Toshiharu Okada(OKI semiconductor) 

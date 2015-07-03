From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Add support to set MTU reservation
 from guest side
Date: Fri, 03 Jul 2015 09:17:29 -0700 (PDT)
Message-ID: <20150703.091729.499431982657478377.davem@davemloft.net>
References: <1435868255-10865-1-git-send-email-haiyangz@microsoft.com>
	<20150703112847.GA28762@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, netdev@vger.kernel.org, olaf@aepfle.de,
	jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
	linux-kernel@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755103AbbGCQRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 12:17:30 -0400
In-Reply-To: <20150703112847.GA28762@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 3 Jul 2015 14:28:47 +0300

> On Thu, Jul 02, 2015 at 01:17:35PM -0700, Haiyang Zhang wrote:
>> When packet encapsulation is in use, the MTU needs to be reduced for
>> headroom reservation.
>> The existing code takes the updated MTU value only from the host side.
>> But vSwitch extensions, such as Open vSwitch, require the flexibility
>> to change the MTU to different values from within a guest during the
>> lifecycle of a vNIC, when the encapsulation protocol is changed. The
>> patch supports this kind of MTU changes.
>> 
>> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
>> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
>> ---
>>  drivers/net/hyperv/netvsc_drv.c   |    3 +--
>>  drivers/net/hyperv/rndis_filter.c |    2 +-
>>  2 files changed, 2 insertions(+), 3 deletions(-)
>> 
>> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
>> index 358475e..68e7ece 100644
>> --- a/drivers/net/hyperv/netvsc_drv.c
>> +++ b/drivers/net/hyperv/netvsc_drv.c
>> @@ -743,8 +743,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
>>  	if (nvdev->nvsp_version >= NVSP_PROTOCOL_VERSION_2)
>>  		limit = NETVSC_MTU - ETH_HLEN;
>>  
>> -	/* Hyper-V hosts don't support MTU < ETH_DATA_LEN (1500) */
>> -	if (mtu < ETH_DATA_LEN || mtu > limit)
>> +	if (mtu < 68 || mtu > limit)
> 
> How did you calculate 68?  Avoid magic numbers like this, make it a
> define.

Agreed.

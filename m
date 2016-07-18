From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH 1/2] net: ethernet: marvell: pxa168_eth: use phydev from
 struct net_device
Date: Tue, 19 Jul 2016 00:00:27 +0200
Message-ID: <578D517B.8090003@gmail.com>
References: <1468791046-19567-1-git-send-email-tremyfr@gmail.com> <f1706f95-8135-d8ec-c65f-edc7d2d63e5e@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jszhang@marvell.com, mugunthanvnm@ti.com,
	a@unstable.cc, fw@strlen.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34472 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbcGRWAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 18:00:34 -0400
In-Reply-To: <f1706f95-8135-d8ec-c65f-edc7d2d63e5e@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 18/07/16 12:14, Sergei Shtylyov wrote:
> Hello.
>
> On 7/18/2016 12:30 AM, Philippe Reynes wrote:
>
>> The private structure contain a pointer to phydev, but the structure
>> net_device already contain such pointer. So we can remove the pointer
>> phydev in the private structure, and update the driver to use the
>> one contained in struct net_device.
>>
>> Signed-off-by: Philippe Reynes<tremyfr@gmail.com>
>> ---
>>   drivers/net/ethernet/marvell/pxa168_eth.c |   36 +++++++++++++----------------
>>   1 files changed, 16 insertions(+), 20 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
>> index 54d5154..d466326 100644
>> --- a/drivers/net/ethernet/marvell/pxa168_eth.c
>> +++ b/drivers/net/ethernet/marvell/pxa168_eth.c
> [...]
>> @@ -973,16 +972,17 @@ static int pxa168_init_phy(struct net_device *dev)
>>   {
>>   	struct pxa168_eth_private *pep = netdev_priv(dev);
>>   	struct ethtool_cmd cmd;
>> +	struct phy_device *phy = NULL;
>
>     Initializer not really needed.

You're right, the first line using phy is an assign, so it's not really usefull.
  
>>   	int err;
>>
>> -	if (pep->phy)
>> +	if (dev->phydev)
>>   		return 0;
>>
>> -	pep->phy = mdiobus_scan(pep->smi_bus, pep->phy_addr);
>> -	if (IS_ERR(pep->phy))
>> -		return PTR_ERR(pep->phy);
>> +	phy = mdiobus_scan(pep->smi_bus, pep->phy_addr);
>> +	if (IS_ERR(phy))
>> +		return PTR_ERR(phy);
>>
>> -	err = phy_connect_direct(dev, pep->phy, pxa168_eth_adjust_link,
>> +	err = phy_connect_direct(dev, phy, pxa168_eth_adjust_link,
>>   				 pep->phy_intf);
>>   	if (err)
>>   		return err;
>
>      Hm, where do you assign 'dev->phydev'?

dev-> phydev is assigned in phy_connect_direct. In fact, phy_connect_direct call
phy_attach_direct, and this last function assign phydev to dev->phydev.

> [...]
>
> MBR, Sergei
>

Regards,
Philippe

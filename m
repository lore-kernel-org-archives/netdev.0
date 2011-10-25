From: Kazunori Kobayashi <kkobayas@igel.co.jp>
Subject: Re: [PATCH] smsc911x: Enable flow control advertisement
Date: Tue, 25 Oct 2011 17:20:26 +0900
Message-ID: <4EA6714A.5010903@igel.co.jp>
References: <1319016114-4781-1-git-send-email-kkobayas@igel.co.jp> <1319027199.23980.47.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	dhobsong@igel.co.jp
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:37387 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601Ab1JYIUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 04:20:41 -0400
Received: by ywm3 with SMTP id 3so255872ywm.19
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 01:20:41 -0700 (PDT)
In-Reply-To: <1319027199.23980.47.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This should be controllable through ethtool; I assume phy_ethtool_sset()
> already covers that.
I found that the flow control could be enabled by changing the
kernel configuration.
I just set CONFIG_SMSC_PHY in "PHY Device support and infrastructure".

Please ignore this patch.

(2011/10/19 21:26), Ben Hutchings wrote:
> On Wed, 2011-10-19 at 18:21 +0900, Kazunori Kobayashi wrote:
>> Enable the advertisement of both symmetric pause and asymmetric pause 
>> flow control capability. 
>>
>> Signed-off-by: Kazunori Kobayashi <kkobayas@igel.co.jp>
>> ---
>>  drivers/net/smsc911x.c |    5 +++++
>>  1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
>> index b9016a3..60c3bc2 100644
>> --- a/drivers/net/smsc911x.c
>> +++ b/drivers/net/smsc911x.c
> 
> This file has been moved.
> 
>> @@ -800,8 +800,13 @@ static void smsc911x_phy_update_flowcontrol(struct smsc911x_data *pdata)
>>  	struct phy_device *phy_dev = pdata->phy_dev;
>>  	u32 afc = smsc911x_reg_read(pdata, AFC_CFG);
>>  	u32 flow;
>> +	u16 miiadv = smsc911x_mii_read(phy_dev->bus, phy_dev->addr,
>> +				       MII_ADVERTISE);
>>  	unsigned long flags;
>>  
>> +	miiadv |= (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
>> +	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_ADVERTISE, miiadv);
> 
> This should be controllable through ethtool; I assume phy_ethtool_sset()
> already covers that.
> 
> Further, it's far too late to change advertising when you're just about
> to resolve what was negotiated.  It has to be done before (re)starting
> autoneg.
> 
> Ben.
> 
>>  	if (phy_dev->duplex == DUPLEX_FULL) {
>>  		u16 lcladv = phy_read(phy_dev, MII_ADVERTISE);
>>  		u16 rmtadv = phy_read(phy_dev, MII_LPA);
> 

-- 
---------------------------------
IGEL Co.,Ltd. Kazunori Kobayashi
kkobayas@igel.co.jp
http://www.igel.co.jp/

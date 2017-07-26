From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Log only PHY state transitions
Date: Wed, 26 Jul 2017 10:24:45 -0700
Message-ID: <8f447bd7-4e30-843b-b111-cf274540969a@gmail.com>
References: <8fc7eb8f-9d64-04c3-a1ca-0cc8eec1ee30@sigmadesigns.com>
 <20170725.123303.483987159585881971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org, slash.tmp@free.fr
To: David Miller <davem@davemloft.net>, marc_gonzalez@sigmadesigns.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36096 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdGZRYv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 13:24:51 -0400
Received: by mail-wr0-f193.google.com with SMTP id y67so21794273wrb.3
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 10:24:50 -0700 (PDT)
In-Reply-To: <20170725.123303.483987159585881971.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2017 12:33 PM, David Miller wrote:
> From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
> Date: Tue, 25 Jul 2017 11:31:46 +0200
> 
>> In the current code, old and new PHY states are always logged.
>> From now on, log only PHY state transitions.
>>
>> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>> ---
>>  drivers/net/phy/phy.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
>> index d0626bf5c540..6bb764e716fc 100644
>> --- a/drivers/net/phy/phy.c
>> +++ b/drivers/net/phy/phy.c
>> @@ -1226,7 +1226,8 @@ void phy_state_machine(struct work_struct *work)
>>  	if (err < 0)
>>  		phy_error(phydev);
>>  
>> -	phydev_dbg(phydev, "PHY state change %s -> %s\n",
>> +	if (old_state != phydev->state)
>> +		phydev_dbg(phydev, "PHY state change %s -> %s\n",
>>  		   phy_state_to_str(old_state),
>>  		   phy_state_to_str(phydev->state));
> 
> Something is not kosher with this indentation at all.

Indeed, please align the two phy_state_to_str() where the opening
parenthesis for phydev_dbg() starts, such this visually looks like:

if (old_state != phydev->state)
	phydev_dbg(phydev, "PHY state change %s -> %s\n",
		   phy_state_to_str(old_state),
		   phy_state_to_str(phydev->state));

Thanks!
-- 
Florian

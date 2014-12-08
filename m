From: Saeed Mahameed <saeedm@mellanox.com>
Subject: Re: [PATCH net-next V1] net/mlx4_en: ethtool force speed when asking
 for autoneg=off
Date: Mon, 8 Dec 2014 11:42:58 +0000
Message-ID: <EA5A1E7F-F3D5-45E9-B819-4863B29E4500@Mellanox.Com>
References: <1417969655-28028-1-git-send-email-amirv@mellanox.com>,<063D6719AE5E284EB5DD2968C1650D6D1CA04B67@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0077.outbound.protection.outlook.com ([157.55.234.77]:15803
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754643AbaLHMPN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 07:15:13 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA04B67@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Dec 8, 2014, at 12:57 PM, David Laight <David.Laight@ACULAB.COM> wrote:
> 
> From: Amir Vadai
>> From: Saeed Mahameed <saeedm@mellanox.com>
>> 
>> Use cmd->autoneg == AUTONEG_DISABLE as a user hint to force specific speed.
>> We don't want to rely on ethtool to calculate advertised link modes when
>> forcing specific speed, a user can request a specific speed and specify
>> "autoneg off" in ethtool command to give a hint for forcing this speed.
> 
> I'm not 100% sure what you are trying to achieve?
Hey David
I am not trying to fix the operating mode of the phy with this patch.
Here i am trying to give the user the ability To let the driver choose what to advertise when user want to force a specific speed using cmd->autoneg =off .

In the driver :
If (cmd->autoneg==off) advertise_according_speed(cmd->speed)
Else advertise(cmd->advertise)

Thanks
-Saeed
> By far the safest way to 'force' a specific speed is to set the
> advertised modes to contain only the desired speed.
> Doing anything else on links that are capable of auto-negotiation
> is a complete recipe for disaster.
> 
> Even if you fix the operating mode of the PHY and MAC you almost
> certainly want to advertise that mode to the remote system.
> 
> Yes, I know this is made all the more complicated by 10/100M autodetect.
> 
>    David
> 
> 
> 

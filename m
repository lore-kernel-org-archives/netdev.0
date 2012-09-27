From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH 2/2] net: ti cpsw ethernet: set IFCTL_{A,B} bits for RMII
 mode
Date: Thu, 27 Sep 2012 13:42:43 +0200
Message-ID: <50643BB3.7080600@gmail.com>
References: <1348680268-8194-1-git-send-email-zonque@gmail.com> <1348680268-8194-2-git-send-email-zonque@gmail.com> <EB1619762EAF8B4E97A227FB77B7E0293E9EBB74@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"Hiremath, Vaibhav" <hvaibhav@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60879 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793Ab2I0Lm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 07:42:59 -0400
Received: by bkcjk13 with SMTP id jk13so1603114bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 04:42:58 -0700 (PDT)
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9EBB74@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.09.2012 20:50, N, Mugunthan V wrote:
>> For RMII mode operation in 100Mbps, the CPSW needs to set the
>> IFCTL_A / IFCTL_B bits in the MACCONTROL register.
>>
>> Signed-off-by: Daniel Mack <zonque@gmail.com>
>> Cc: Mugunthan V N <mugunthanvnm@ti.com>
>> Cc: Vaibhav Hiremath <hvaibhav@ti.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> ---
>>  drivers/net/ethernet/ti/cpsw.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>> b/drivers/net/ethernet/ti/cpsw.c
>> index 3d7594e..d88dbfa 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -386,6 +386,12 @@ static void _cpsw_adjust_link(struct cpsw_slave
>> *slave,
>>  			mac_control |= BIT(7);	/* GIGABITEN	*/
>>  		if (phy->duplex)
>>  			mac_control |= BIT(0);	/* FULLDUPLEXEN	*/
>> +
>> +		/* set speed_in input in case RMII mode is used in >10Mbps
>> */
>> +		if (phy->speed > 10 && slave->slave_num < 2 &&
>> +		    phy->interface == PHY_INTERFACE_MODE_RMII)
>> +			mac_control |= BIT(15 + slave->slave_num);
> 
> Mac control register is separate for both the slaves and has same bit definitions,
> Bit 15 has to be set for 100Mbps link for RMII and RGMII Phy interface to control
> the RMII/RGMII gasket and in GMII this bit is Un-used by CPSW.
> For slave 1, Bit 16 is set with the above code which is not used control the
> RMII/RGMII gasket control. So it is not required to pass the Phy mode from DT.
> This patch has to be reworked to set Bit 15 with any Phy mode connected.

Hmm, that's interesting. I read the datasheet differently, but I believe
you're right.

> The original driver present was tested with GMII (Beagle Bone A5) and
> RGMII (AM3358 EVM) phy , but CPSW works fine without setting this bit in
> RGMII phymode so this issue was not caught in testing.

Yes, it used to work fine for me too until the hardware was reworked
from RGMII to RMII :)

Thanks a lot for the review - I just tested that setting bit 15 for all
PHY interface modes works for me as well, so I'm fine with that
solution. Will repost a new patch.


Daniel

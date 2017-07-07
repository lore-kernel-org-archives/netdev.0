From: Richard Leitner <richard.leitner@skidata.com>
Subject: Re: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable
 option
Date: Fri, 7 Jul 2017 11:52:50 +0200
Message-ID: <6de114cb-4521-4bb2-d0a3-4aea32936bd3@skidata.com>
References: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
 <1499346330-12166-2-git-send-email-richard.leitner@skidata.com>
 <AM4PR0401MB2260ECD4508E26FF16670004FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <81105c77-d48f-271b-2de1-c877b9413184@skidata.com>
 <AM4PR0401MB226089839458F5F92C3B1F39FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "dev@g0hl1n.net" <dev@g0hl1n.net>, Andrew Lunn <andrew@lunn.ch>
To: Andy Duan <fugang.duan@nxp.com>,
        "robh+dt@kernel.org" <robh+dt@kernel.org>,
        "mark.rutland@arm.com" <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM4PR0401MB226089839458F5F92C3B1F39FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 07/07/2017 09:03 AM, Andy Duan wrote:
> From: Richard Leitner <richard.leitner@skidata.com> Sent: Friday, July 07, 2017 1:51 PM
>>> Since it is common issue so long as using the PHY, can you move it into smsc
>> phy driver like in .smsc_phy_reset() function ?
>>> And get the reset pin from phy dts node.
>>
>> Some more points that come into my mind:
>>  - The smsc_phy_reset function is registered as "soft_reset". Would it be OK to
>> use nRST in it?
>
> It is not reasonable.
>
>>  - Would it be OK to call the phy_init_hw function from within the
>> smsc_phy_reset?
>
> No, phy_init_hw() already call .drv->soft_reset().
>
>>  - IMHO I'd have to move the reset gpio binding inside the phy node then. Isn't
>> that a pretty big change doing that for all PHYs/FECs? Would it be "worth" it?
>>
> To make the change to be common, there have big change for phy driver.
> Maybe somebody can give one good suggestion/solution for it.

Sorry, I don't think I understood everything correctly:

1. The "phy-reset-gpios" binding should go inside the phy node. This 
will cause to *change ALL FEC and PHY drivers*. Correct?

2. Add an additonal "hard reset" function to the PHY driver which 
handles the "phy-reset-gpios". Correct?

3. Who should then trigger the "hard reset" of the PHY? phy_init_hw? The 
FEC?

The point is that the LAN8710 is currently not always working correctly, 
therefore this small change was proposed. Should we really change all 
PHY/FECs only because of this?
Furthermore one problem still remains: The enet_refclk is controlled by 
the FEC. How does the PHY recognize when it was disabled/enabled?

>
> Andy
>

kind regards,
Richard.L

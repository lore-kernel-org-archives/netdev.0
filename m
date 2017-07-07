From: Richard Leitner <richard.leitner@skidata.com>
Subject: Re: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable
 option
Date: Fri, 7 Jul 2017 13:16:54 +0200
Message-ID: <b68f444e-cea4-acaa-d1e9-7955a577ed35@skidata.com>
References: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
 <1499346330-12166-2-git-send-email-richard.leitner@skidata.com>
 <AM4PR0401MB2260ECD4508E26FF16670004FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <81105c77-d48f-271b-2de1-c877b9413184@skidata.com>
 <AM4PR0401MB226089839458F5F92C3B1F39FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <6de114cb-4521-4bb2-d0a3-4aea32936bd3@skidata.com>
 <AM4PR0401MB22609FFACD2BB51247709936FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
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
In-Reply-To: <AM4PR0401MB22609FFACD2BB51247709936FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy,
thanks for the clarifications!

On 07/07/2017 01:08 PM, Andy Duan wrote:
>> 3. Who should then trigger the "hard reset" of the PHY? phy_init_hw? The FEC?
>>
>> The point is that the LAN8710 is currently not always working correctly,
>> therefore this small change was proposed. Should we really change all
>> PHY/FECs only because of this?
>> Furthermore one problem still remains: The enet_refclk is controlled by the
>> FEC. How does the PHY recognize when it was disabled/enabled?
>>
> Your patch is workaround for the issue. As you pointed out these is a common issue.
> So we hope to get a better solution to handle these in common code.

Ok. I'm fine with moving the phy-reset-gpios binding into the PHY. But 
one question still remains: Who should then trigger the "hard reset" of 
the PHY?

The PHY itself doesn't "know" when the refclk is turned off/on. So the 
FEC still must call some function of the PHY after the clock was enabled 
again. So the phy-reset-after-clk-enable property will remain in the fec 
node? Or am I missing something?

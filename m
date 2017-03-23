From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: handle state correctly in phy_stop_machine
Date: Thu, 23 Mar 2017 14:45:54 -0700
Message-ID: <cca58f8b-0d9b-fb17-2ba3-2fd11bf88efe@gmail.com>
References: <1490214421-7269-1-git-send-email-zach.brown@ni.com>
 <d3696191-fabc-d150-eb3f-df60f3bcfbe3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Zach Brown <zach.brown@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d3696191-fabc-d150-eb3f-df60f3bcfbe3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/23/2017 02:41 PM, Florian Fainelli wrote:
> On 03/22/2017 01:27 PM, Zach Brown wrote:
>> From: Nathan Sullivan <nathan.sullivan@ni.com>
>>
>> If the PHY is halted on stop, then do not set the state to PHY_UP.  This
>> ensures the phy will be restarted later in phy_start when the machine is
>> started again.
> 
> So essentially what you want to "defeat" here is entering phy_start()
> with PHY_UP therefore not run this part:
> 
>         case PHY_HALTED:
>                 /* make sure interrupts are re-enabled for the PHY */
>                 if (phydev->irq != PHY_POLL) {
>                         err = phy_enable_interrupts(phydev);
>                         if (err < 0)
>                                 break;
>                 }
> 
>                 phydev->state = PHY_RESUMING;
>                 do_resume = true;
>                 break;
> 
> which is what re-enables interrupts and makes sure the PHY is resumed,
> right?
> 
> If that's the scenario, I guess:
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

And almost forgot:

Fixes: 00db8189d984 ("This patch adds a PHY Abstraction Layer to the
Linux Kernel, enabling ethernet drivers to remain as ignorant as is
reasonable of the connected PHY's design and operation details.")
-- 
Florian

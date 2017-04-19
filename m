From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: phy: fix auto-negotiation stall due to unavailable
 interrupt
Date: Wed, 19 Apr 2017 21:11:43 +0300
Message-ID: <129784d6-9020-6d01-4b3d-4740ac61368b@cogentembedded.com>
References: <1492609604-16359-1-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Kochetkov <al.kochet@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492609604-16359-1-git-send-email-al.kochet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 04/19/2017 04:46 PM, Alexander Kochetkov wrote:

> The problem I fix related to SMSC LAN8710/LAN8720 PHY handled using
> interrupts. During power-up cycle the PHY do auto-negotiation, generate
> interrupt and set BMSR_ANEGCOMPLETE flag. Interrupt is handled by PHY
> state machine but doesn't update link because PHY is in PHY_READY state.
> After some time MAC bring up and connect with PHY. It start PHY using
> phy_start(). During startup PHY change state to PHY_AN but doesn't
> set BMCR_ANRESTART flag due to genphy_config_aneg() doesn't update MII_BMCR
> because there no new to advertising. As a result, state machine wait for
           ^^^^^^^^^^^^    ^^^^^^^^^^^
    There is no new what? Advertize, maybe?

> interrupt from PHY and nether get "link is up". Because BMSR_ANEGCOMPLETE
                          ^^^^^^
    Never, neither? :-)

> already set the patch schedule check link without waiting interrupt.
> In case genphy_config_aneg() update MII_BMCR and set BMCR_ANRESTART
> flag, BMSR_ANEGCOMPLETE will be cleared and state machine will continue
> on auto-negotiation interrupt.
>
> Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
[...]

MBR, Sergei

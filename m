From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH V2 0/5] e1000e: fix nic not boot after rebooting
Date: Thu, 14 May 2015 19:10:22 +0200
Message-ID: <20150514171022.GA27968@1wt.eu>
References: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: Zhu Yanjun <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:35783 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932759AbbENRK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2015 13:10:26 -0400
Content-Disposition: inline
In-Reply-To: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Dec 16, 2014 at 06:28:15PM +0800, Zhu Yanjun wrote:
> With kernel 2.6.x, e1000e with 82577/8/9 sometimes will not boot
> after rebooting. 
> 
> If a kernel 2.6.x board with 82577/8/9 e1000e nic is rebooted for 
> 100 times, there are 7~8 times that 82577/8/9 e1000e nic will not boot 
> normally.
> 
> V2:
> Follow the advice from Willy, the wrong upstream commit IDs in these
> 5 patches commit messages are fixed.
> 
> Zhu Yanjun (5):
>   e1000e: reset MAC-PHY interconnect on 82577/82578
>   e1000e: workaround EEPROM configuration change on 82579 on kernel
>     2.6.x
>   e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked
>   e1000e: update workaround for 82579 intermittently disabled during
>     S0->Sx
>   e1000e: cleanup use of check_reset_block function pointer

I queued this series for 2.6.32.66 but found that it doesn't build
because patch 2 adds this test :

@@ -2685,6 +2694,14 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
        ew32(CTRL, (ctrl | E1000_CTRL_RST));                            
        msleep(20);

+       /* Set Phy Config Counter to 50msec */
+       if (hw->mac.type == e1000_pch2lan) {
+               u32 phycc_reg = er32(FEXTNVM3);
+               phycc_reg &= ~E1000_FEXTNVM3_PHY_CFG_COUNTER_MASK;
+               phycc_reg |= E1000_FEXTNVM3_PHY_CFG_COUNTER_50MSEC;
+               ew32(FEXTNVM3, phycc_reg);
+       }
+

And e1000_pch2lan doesn't appear in the enum in 2.6.32 hence this
type is never assigned. Thus I'm wondering if I should just drop
this test (trivial) or if there are other parts that may not be
relevant to this kernel version.

Any hint will be greatly appreciated.

Thanks!
Willy

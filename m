From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] net: phy: leds: Fix truncated LED trigger names
 and crashes
Date: Wed, 25 Jan 2017 14:40:42 -0500 (EST)
Message-ID: <20170125.144042.372817990268077333.davem@davemloft.net>
References: <1485340790-10785-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, zach.brown@ni.com,
        volodymyr.bendiuga@gmail.com, andrew@lunn.ch,
        magnus.oberg@westermo.se, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485340790-10785-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Wed, 25 Jan 2017 11:39:47 +0100

> I started seeing crashes during s2ram and poweroff on all my ARM boards,
> like:
> 
>     Unable to handle kernel NULL pointer dereference at virtual address 00000000
>     ...
>     [<c04116d4>] (__list_del_entry_valid) from [<c05e8948>] (led_trigger_unregister+0x34/0xcc)
>     [<c05e8948>] (led_trigger_unregister) from [<c05336c4>] (phy_led_triggers_unregister+0x28/0x34)
>     [<c05336c4>] (phy_led_triggers_unregister) from [<c0531d44>] (phy_detach+0x30/0x74)
>     [<c0531d44>] (phy_detach) from [<c0538bdc>] (sh_eth_close+0x64/0x9c)
>     [<c0538bdc>] (sh_eth_close) from [<c04d4ce0>] (dpm_run_callback+0x48/0xc8)
> 
> or:
> 
>     list_del corruption. prev->next should be dede6540, but was 2e323931
>     ------------[ cut here ]------------
>     kernel BUG at lib/list_debug.c:52!
>     ...
>     [<c02f6d70>] (__list_del_entry_valid) from [<c0425168>] (led_trigger_unregister+0x34/0xcc)
>     [<c0425168>] (led_trigger_unregister) from [<c03a05a0>] (phy_led_triggers_unregister+0x28/0x34)
>     [<c03a05a0>] (phy_led_triggers_unregister) from [<c039ec04>] (phy_detach+0x30/0x74)
>     [<c039ec04>] (phy_detach) from [<c03a4fc0>] (sh_eth_close+0x6c/0xa4)
>     [<c03a4fc0>] (sh_eth_close) from [<c0483234>] (__dev_close_many+0xac/0xd0)
> 
> As the only clue was a kernel message like
> 
>     sh-eth ee700000.ethernet eth0: No phy led trigger registered for speed(100)
> 
> I had to bisected this, leading to commit 4567d686f5c6d955 ("phy:
> increase size of MII_BUS_ID_SIZE and bus_id").  Reverting that commit
> fixed the issue.
> 
> More investigation revealed the crashes are due to the combination of
> two things:
>   - Truncated LED trigger names, leading to duplicate names, and
>     registration failures,
>   - Bad error handling in case of registration failures.
> 
> Both are fixed by this patch series.

Thanks for tracking this down and fixing it.

Series applied, thanks.

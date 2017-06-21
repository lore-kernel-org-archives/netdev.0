From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] mwifiex: fixes the unexpected be printed log by default
Date: Wed, 21 Jun 2017 15:25:20 +0000 (UTC)
Message-ID: <20170621152520.5B96060250@smtp.codeaurora.org>
References: <1497438416-24665-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yangzy@marvell.com, jeffy.chen@rock-chips.com,
        briannorris@chromium.org, linux-kernel@vger.kernel.org,
        Caesar Wang <wxt@rock-chips.com>,
        Xinming Hu <huxm@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-wireless@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        netdev@vger.kernel.org
To: Caesar Wang <wxt@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58276 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752339AbdFUQok (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 12:44:40 -0400
In-Reply-To: <1497438416-24665-1-git-send-email-wxt@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Caesar Wang <wxt@rock-chips.com> wrote:

> This patch uses WARN level is not printed by default.
> 
> In some cases, some boards have always met the unused log be printed as
> follows.
> ...
> [23193.523182] mwifiex_pcie 0000:01:00.0: mwifiex_get_cfp:
> cannot find cfp by band 2    & channel=13 freq=0
> [23378.633684] mwifiex_pcie 0000:01:00.0: mwifiex_get_cfp:
> cannot find cfp by band 2    & channel=13 freq=0
> 
> Due to we used the wifi default area was US and didn't support 12~14
> channels. As Frequencies:
> * 2412 MHz [1] (30.0 dBm)
> * 2417 MHz [2] (30.0 dBm)
> * 2422 MHz [3] (30.0 dBm)
> * 2427 MHz [4] (30.0 dBm)
> * 2432 MHz [5] (30.0 dBm)
> * 2437 MHz [6] (30.0 dBm)
> * 2442 MHz [7] (30.0 dBm)
> * 2447 MHz [8] (30.0 dBm)
> * 2452 MHz [9] (30.0 dBm)
> * 2457 MHz [10] (30.0 dBm)
> * 2462 MHz [11] (30.0 dBm)
> * 2467 MHz [12] (disabled)
> * 2472 MHz [13] (disabled)
> * 2484 MHz [14] (disabled)
> 
> Also, as the commit 1b499cb72f26b
> ("mwifiex: disable channel filtering feature in firmware"), it proved to
> be a feature to get better scan result from overlapping channel.
> 
> Even there could be AP from overlapping channel (might be 12/13/14
> in this case), it will be filtered depend on reg domain rules.
> e.g:
> ...
> if (ch->flags & IEEE80211_CHAN_DISABLED)
>         continue;
> 
> So it should not been an ERROR, use the WARN level to instead it for now.
> 
> Signed-off-by: Caesar Wang <wxt@rock-chips.com>
> Acked-by: Xinming Hu <huxm@marvell.com>

Patch applied to wireless-drivers-next.git, thanks.

421ba82c676b mwifiex: fixes the unexpected be printed log by default

-- 
https://patchwork.kernel.org/patch/9786123/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches

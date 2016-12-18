From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 1/5] sh_eth: add generic wake-on-lan support via magic
 packet
Date: Sun, 18 Dec 2016 23:26:11 +0300
Message-ID: <87e3f9e6-0f5a-986c-772d-006cb25b9fd9@cogentembedded.com>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
 <20161212160931.6478-2-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:36331 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbcLRU0Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2016 15:26:16 -0500
Received: by mail-lf0-f44.google.com with SMTP id t196so41615529lff.3
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2016 12:26:15 -0800 (PST)
In-Reply-To: <20161212160931.6478-2-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/12/2016 07:09 PM, Niklas Söderlund wrote:

> Add generic functionality to support Wake-on-Lan using MagicPacket which
> are supported by at least a few versions of sh_eth. Only add
> functionality for WoL, no specific sh_eth version are marked to support

    Versions.

> WoL yet.
>
> WoL is enabled in the suspend callback by setting MagicPacket detection
> and disabling all interrupts expect MagicPacket. In the resume path the
> driver needs to reset the hardware to rearm the WoL logic, this prevents
> the driver from simply restoring the registers and to take advantage of
> that sh_eth was not suspended to reduce resume time. To reset the
> hardware the driver close and reopens the device just like it would do

    Closes.

> in a normal suspend/resume scenario without WoL enabled, but it both
> close and open the device in the resume callback since the device needs

    Closes and opens.

> to be open for WoL to work.

> One quirk needed for WoL is that the module clock needs to be prevented
> from being switched off by Runtime PM. To keep the clock alive the

    I tried to find the code in question and failed, getting muddled in the 
RPM maze. Could you point at this code for my education? :-)

> suspend callback need to call clk_enable() directly to increase the

    My main concern is why we need to manipulate the clock directly --
can't you call RPM to achieve the same effect?

> usage count of the clock. Then when Runtime PM decreases the clock usage
> count it won't reach 0 and be switched off.

    You mean it does this even though we don't call pr_runtime_put_sync()
as done in sh_eth_close()?

> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
[...]

MBR, Sergei

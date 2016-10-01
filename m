From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Sat, 1 Oct 2016 22:15:16 +0200
Message-ID: <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
 <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Johnson Leung <r58129@freescale.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37023 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbcJAUPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 16:15:38 -0400
Received: by mail-wm0-f52.google.com with SMTP id b201so11675125wmb.0
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 13:15:37 -0700 (PDT)
In-Reply-To: <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 5:30 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> Also you could check the AXI tuning and PBL value. To be honest
> (thinking about your problem) I can actually suspect some related
> problem on bus setup. So I suggest you to play with these value
> (better if you ask for having values from HW validation on your side).
> Otherwise the stmmac uses a default that cannot be good for your
> platform. For example, sometime I have seen that PBL is better if
> reduced to 8 instead of 32 and w/o 4xPBL...
unfortunately the original kernel/firmware shipped with my device
seems to be also affected by that TX bug, so comparing with the
"stock" values does not work for me.
Additionally I should mention that this is an end-consumer device, so
I cannot simply ask the HW guys for the correct values.

I dumped the following registers (which I thought might be related to
this issue) on the original kernel (0xc9410000 is the location of the
stmmac IP block):
for REG in 0x00000018 0x00000030 0x0000003c 0x00001000 0x00001018
0x00001028; do printf "%x 1\n" $((REG + 0xc9410000)) >
/sys/kernel/debug/aml_reg/dump; cat /sys/kernel/debug/aml_reg/dump;
done

on my device this results in:
[0xc9410018] = 0x2000000
[0xc9410030] = 0x0
[0xc941003c] = 0x0
[0xc9411000] = 0x1100802
[0xc9411018] = 0x2202006
[0xc9411028] = 0x0

maybe someone else could try the command from above on his device
(running the original Amlogic kernel).
please also state if ethernet is working properly on the original
kernel (and preferably which device/board this is).


Regards,
Martin

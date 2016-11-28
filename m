From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: stmmac ethernet in kernel 4.4: coalescing related pauses?
Date: Mon, 28 Nov 2016 14:07:51 +0100
Message-ID: <f14255ee-7fa8-afef-23ec-fc4f9a74eec8@marvell.com>
References: <20161123105125.GA26394@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Pavel Machek <pavel@ucw.cz>, <peppe.cavallaro@st.com>,
        <netdev@vger.kernel.org>,
        kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:48020 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753751AbcK1NJH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 08:09:07 -0500
In-Reply-To: <20161123105125.GA26394@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pavel,

On 23.11.2016 11:51, Pavel Machek wrote:

> I'm debugging strange delays during transmit in stmmac driver. They
> seem to be present in 4.4 kernel (and older kernels, too). Workload is
> burst of udp packets being sent, pause, burst of udp packets, ...
>
> Test code is attached, I use these parameters for testing:
>
> ./udp-test raw 10.0.0.6 1234 1000 100 30
>
> The delays seem to be related to coalescing:
>
> drivers/net/ethernet/stmicro/stmmac/common.h
> #define STMMAC_COAL_TX_TIMER    40000
> #define STMMAC_MAX_COAL_TX_TICK 100000
> #define STMMAC_TX_MAX_FRAMES    256
>
> If I lower the parameters, delays are gone, but I get netdev watchdog
> backtrace followed by broken driver.
>
> Any ideas what is going on there?
>
> [I'm currently trying to get newer kernels working on affected
> hardware.]
>
> Best regards,
>
> 									Pavel

I once encountered a similar behaviour with a driver. The reason was that the socket
queue limit was temporarily exhausted because the irq handler did not free the tx skbs
fast enough (that driver also used irq coalescing).
Calling skb_orphan() in the xmit handler made this issue disappear.

Regards,
Lino  

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 4/4] sh_eth: Fix serialisation of interrupt disable
 with interrupt & NAPI handlers
Date: Thu, 22 Jan 2015 19:35:06 +0300
Message-ID: <54C126BA.4030807@cogentembedded.com>
References: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>	 <1421930648.1222.289.camel@xylophone.i.decadent.org.uk>	 <54C1002D.7090508@cogentembedded.com> <1421939177.1222.298.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S.Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:38908 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbbAVQfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 11:35:12 -0500
Received: by mail-la0-f43.google.com with SMTP id q1so2658628lam.2
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 08:35:10 -0800 (PST)
In-Reply-To: <1421939177.1222.298.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/22/2015 06:06 PM, Ben Hutchings wrote:

>>> In order to stop the RX path accessing the RX ring while it's being
>>> stopped or resized, we clear the interrupt mask (EESIPR) and then call
>>> free_irq() or synchronise_irq().  This is insufficient because the
>>> interrupt handler or NAPI poller may set EESIPR again after we clear
>>> it.

>>      Hm, how come the interrupt handler gets called when we have disabled all
>> interrupts?

> It may be running on another processor and racing with the function that
> clears EESIPR.

    Ah, I didn't think about SMP... but then we need more spinlock protection 
instead, no?

>> Is it unmaskable EESR.ECI interrupt? BTW, I'm not seeing where the
>> interrupt handler enables interrupts again; only NAPI poller does that AFAIK.

> Normally it only clears EESR_RX_CHECK, but as it cannot atomically clear
> a single bit of EESIPR this can result in setting other bits.

    This is again only possible on SMP kernel, right?

[...]

> Ben.

WBR, Sergei

From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH 2/2] net: ethernet: nb8800: Fix RGMII TX clock delay setup
Date: Thu, 20 Jul 2017 14:33:00 +0200
Message-ID: <54f5bd21-766d-d9de-3b15-a01fd5ee6035@free.fr>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
 <61b71d12-4e3a-edbe-1d69-c66e7cf46d8e@sigmadesigns.com>
 <yw1xzic0qrcg.fsf@mansr.com> <001a7afd-364d-359e-1478-e057c9083f73@free.fr>
 <d8121f82-dffd-22c7-1209-a3c2329703e5@gmail.com>
 <05cbc32e-a4af-1c81-128b-bc5d2206d24a@free.fr>
 <bf484952-15ae-b385-6b54-4d07b3bc2b29@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:43968 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933882AbdGTMdk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Jul 2017 08:33:40 -0400
In-Reply-To: <bf484952-15ae-b385-6b54-4d07b3bc2b29@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/07/2017 23:34, Florian Fainelli wrote:

> How about you start reading the RGMII specification so we can at least,
> if nothing else agree on the terminology? It's public:
> 
> http://web.archive.org/web/20160303171328/http://www.hp.com/rnd/pdfs/RGMIIv2_0_final_hp.pdf

Thanks for linking the spec. Having no EE training,
I am ill-equipped to interpret the timings table.

As you pointed out, the spec states that the
"Data to Clock input Skew (at Receiver)"
must be within [ 1.0, 2.6 ] ns.

I understand that 2 ns is 1/4 of a 125 MHz period,
but it's not clear to me why the above interval is
centered at 1.8 instead of 2.0 ns.

Also, the AR8035 PHY offers 4 possible TX clock delays:
{ 0.25, 1.3, 2.4, 3.4 } according to their doc.
The two extremes are outside the interval, when would
they be useful? In case the transmitter adds "bad" skew?

Why doesn't the PHY support 1.8/2.0? Is it perhaps
unable to, because of PLL limitations?

It's also not clear to me if wire length has any
influence on the required skew. I would say "no".
I think signal propagation time has nothing to do
with clock skew (as long as both wires are roughly
the same length).

> Some Ethernet controllers let you change it, some don't, if nb8800
> allows it, it's good for testing in that it packs more frames per
> quantum of time. If not, do you have at least a FCS error counter?

I'll have a closer look, and test with iPerf3.
Or is there a better benchmark? I will look for
an inter-packet gap knob and FCS error counter.

> I completely understand what you want to solve but I suspect you will
> have to do it in a way where you either accept that you may not be fully
> compliant with the now clarified "phy-mode" description, in order not to
> break other people's set up that were already non-compliant (can't blame
> them, they did not know back then), or you will have to use additional
> MAC properties to override the delay settings on the MAC or PHY side.

I think I need to give up the notion of "fixing"
the at803x driver. Some boards rely on the fact
that RX clock delay is enabled by default, like
am335x-evm using "rgmii-txid" instead of "rgmii-id".

My board needs to enable both internal delays,
so I don't need the PHY patch. I will only fix
the MAC driver and the DTS.

Regards.

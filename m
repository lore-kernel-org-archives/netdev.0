From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 3/4] Documentation: net: phy: Add blurb about
 RGMII
Date: Mon, 28 Nov 2016 11:47:44 -0800
Message-ID: <c4146d81-712e-0f8d-f7f3-4a229efd99e6@gmail.com>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
 <20161127184449.12351-4-f.fainelli@gmail.com>
 <4c71a69c-2942-f177-ef25-04686f5e4149@laposte.net>
 <60473447-423c-7dff-6647-cce7cf2d4ab2@gmail.com>
 <b6a19ca6-8bda-8573-eb7b-9ed7f80ca480@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com
To: Mason <slash.tmp@free.fr>, Sebastian Frias <sf84@laposte.net>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34728 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752333AbcK1Trr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 14:47:47 -0500
Received: by mail-pg0-f68.google.com with SMTP id e9so13922505pgc.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 11:47:47 -0800 (PST)
In-Reply-To: <b6a19ca6-8bda-8573-eb7b-9ed7f80ca480@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 11:15 AM, Mason wrote:
> On 28/11/2016 18:43, Florian Fainelli wrote:
> 
>> On 11/28/2016 02:34 AM, Sebastian Frias wrote:
>>
>>> For what is worth, the Atheros at803x driver comes with RX delay enabled
>>> as per HW reset.
>>
>> Always, or is this a behavior possibly defined via a stra-pin that can
>> be changed?
> 
> Here's the data sheet:
> 
>   http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf
> 
> 4.2.25 rgmii rx clock delay control
> Offset: 0x00
> bit 15: Control bit for rgmii interface rx clock delay:
> 1 = rgmii rx clock delay enable
> 0 = rgmii rx clock delay disable
> HW Rst. 1
> SW Rst. 1
> 
> As far as I can tell, rx delay is enabled by default, always.
> 
> The "Features" list mentions
> "RGMII timing modes support internal delay and external delay on Rx path"
> (Not sure about the internal vs external distinction.)
> 
> Table 3-6. RGMII AC Characteristics — no Internal Delay
> Table 3-7. RGMII AC Characteristics — with internal delay added (Default)
> 
> Delay is 2 ns apparently.
> 
> There's also
> 4.2.27 Hib ctrl and rgmii gtx clock delay register
> Offset: 0x0B
> 
> bits 6:5 Gtx_dly_val
> Select the delay of gtx_clk.
> 00:0.25ns
> 01:1.3ns
> 10:2.4ns
> 11:3.4ns
> 
> I don't know what that is used for.
> Maybe this is the external vs internal delay?

First, this has little to do with the initial patch series being
discussed now, and second, this still looks like an internal delay
programming, just that it applies to the received transmit clock from
the MAC, that's how I read it though.
-- 
Florian

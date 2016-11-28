From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH net-next v2 3/4] Documentation: net: phy: Add blurb about
 RGMII
Date: Mon, 28 Nov 2016 20:15:27 +0100
Message-ID: <b6a19ca6-8bda-8573-eb7b-9ed7f80ca480@free.fr>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
 <20161127184449.12351-4-f.fainelli@gmail.com>
 <4c71a69c-2942-f177-ef25-04686f5e4149@laposte.net>
 <60473447-423c-7dff-6647-cce7cf2d4ab2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        Sebastian Frias <sf84@laposte.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:6629 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754361AbcK1TP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 14:15:59 -0500
In-Reply-To: <60473447-423c-7dff-6647-cce7cf2d4ab2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/11/2016 18:43, Florian Fainelli wrote:

> On 11/28/2016 02:34 AM, Sebastian Frias wrote:
>
>> For what is worth, the Atheros at803x driver comes with RX delay enabled
>> as per HW reset.
> 
> Always, or is this a behavior possibly defined via a stra-pin that can
> be changed?

Here's the data sheet:

  http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf

4.2.25 rgmii rx clock delay control
Offset: 0x00
bit 15: Control bit for rgmii interface rx clock delay:
1 = rgmii rx clock delay enable
0 = rgmii rx clock delay disable
HW Rst. 1
SW Rst. 1

As far as I can tell, rx delay is enabled by default, always.

The "Features" list mentions
"RGMII timing modes support internal delay and external delay on Rx path"
(Not sure about the internal vs external distinction.)

Table 3-6. RGMII AC Characteristics — no Internal Delay
Table 3-7. RGMII AC Characteristics — with internal delay added (Default)

Delay is 2 ns apparently.

There's also
4.2.27 Hib ctrl and rgmii gtx clock delay register
Offset: 0x0B

bits 6:5 Gtx_dly_val
Select the delay of gtx_clk.
00:0.25ns
01:1.3ns
10:2.4ns
11:3.4ns

I don't know what that is used for.
Maybe this is the external vs internal delay?

Regards.

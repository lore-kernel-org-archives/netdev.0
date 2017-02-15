From: Anssi Hannula <anssi.hannula@bitwise.fi>
Subject: Re: [PATCH 1/2] net: xilinx_emaclite: fix receive buffer overflow
Date: Wed, 15 Feb 2017 10:28:57 +0200
Message-ID: <62dad5ad-cafb-7569-b010-cb355f7affc7@bitwise.fi>
References: <20170214171145.26953-1-anssi.hannula@bitwise.fi>
 <20170214.151259.1157334352658192111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bitwise.fi ([109.204.228.163]:54634 "EHLO mail.bitwise.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750716AbdBOI3E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 03:29:04 -0500
In-Reply-To: <20170214.151259.1157334352658192111.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.2.2017 22:12, David Miller wrote:
> From: Anssi Hannula <anssi.hannula@bitwise.fi>
> Date: Tue, 14 Feb 2017 19:11:44 +0200
>
>> xilinx_emaclite looks at the received data to try to determine the
>> Ethernet packet length but does not properly clamp it if
>> proto_type == ETH_P_IP or 1500 < proto_type <= 1518, causing a buffer
>> overflow and a panic via skb_panic() as the length exceeds the allocated
>> skb size.
>>
>> Fix those cases.
>>
>> Also add an additional unconditional check with WARN_ON() at the end.
>>
>> Signed-off-by: Anssi Hannula <anssi.hannula@bitwise.fi>
>> Fixes: bb81b2ddfa19 ("net: add Xilinx emac lite device driver")
> Why does this driver do all of this crazy stuff parsing the packet
> headers?
>
> It should be able to just read the length provided by the device
> at XEL_RPLR_OFFSET and just use that.

Looks like XEL_RPLR_OFFSET == XEL_HEADER_OFFSET + XEL_RXBUFF_OFFSET and
that is where the driver reads the on-wire Type/Length field.

Looking through the product guide [1] I don't see the actual receive
packet length provided anywhere, so I guess that is why the crazy stuff
is done.

[1]
https://www.xilinx.com/support/documentation/ip_documentation/axi_ethernetlite/v3_0/pg135-axi-ethernetlite.pdf

-- 
Anssi Hannula / Bitwise Oy
+358503803997

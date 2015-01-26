From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Mon, 26 Jan 2015 10:16:18 +0000
Message-ID: <54C613F2.5090507@linn.co.uk>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk> <20150123105114.GB23493@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"abrestic@chromium.org" <abrestic@chromium.org>
To: Mark Rutland <mark.rutland@arm.com>,
	Stathis Voukelatos <stathisv70@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linn.co.uk ([195.59.102.251]:61953 "EHLO mail.linn.co.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755533AbbAZKQc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 05:16:32 -0500
In-Reply-To: <20150123105114.GB23493@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 23/01/15 10:51, Mark Rutland wrote:
>
> diff --git a/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
> new file mode 100644
> index 0000000..6b6e105
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
> @@ -0,0 +1,27 @@
> +* Linn Products Ethernet Packet Sniffer
> +
> +Required properties:
> +- compatible : must be "linn,eth-sniffer"
> +- reg : physical addresses and sizes of registers. Must contain 3 entries:
> +          first entry: registers memory space
> +          second entry: TX command memory
> +          third entry: RX command memory
> Just to check: are those memories are part of the packet sniffer device,
> or are carveouts from other memory?
Yes, the 3 memory areas are part of the packet sniffer module.
>> +- fifo-block-words : number of words in one data FIFO entry
>> +
>> +Example:
>> +
>> +sniffer@1814a000 {
>> +        compatible = "linn,eth-sniffer";
>> +        reg = <0x1814a000 0x100>, <0x1814a400 0x400>, <0x1814a800 0x400>;
>> +        reg-names = "regs", "tx-ram", "rx-ram";
>> +        interrupts = <GIC_SHARED 58 IRQ_TYPE_LEVEL_HIGH>;
>> +        interrupt-names = "eth-sniffer-irq";
>> +        clocks = <&system_clk>;
>> +        clock-names = "sys";
>> +        fifo-block-words = <4>;
>> +    };
> Surely the relationship between the sniffer, MAC, and PHY should be
> described, so we know which interface the sniffer is related to?
>
The packet sniffer sits between the MAC and the PHY and monitors TX or RX
packets, or both. Will add a description in the binding doc.

Your other suggestions too, will be incorporated in the next version of
the patch set.

Thank you,
Stathis

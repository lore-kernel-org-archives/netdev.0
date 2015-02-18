From: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Subject: Re: [PATCH v2 1/3] Ethernet packet sniffer: Device tree binding and
 vendor prefix
Date: Wed, 18 Feb 2015 13:56:03 +0000
Message-ID: <54E499F3.4020403@linn.co.uk>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk> <0a86907642a97e5bd880f69299664232fcffaf9d.1424181053.git.stathis.voukelatos@linn.co.uk> <20150217145124.GM8994@leverpostej> <54E36AAC.7010308@linn.co.uk> <20150217163527.GR8994@leverpostej> <54E376AF.80602@linn.co.uk> <20150217173000.GT8994@leverpostej> <54E45E06.2020609@linn.co.uk> <20150218121150.GA29429@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org" <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150218121150.GA29429@leverpostej>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi Mark,

On 18/02/15 12:11, Mark Rutland wrote:
>>
>> Counters can often have a divider applied to their input clock and
>> therefore run at a scaled down frequency. This is not the case in the
>> first SoC where the sniffer is used, so for simplicity I can modify as
>> you suggest and remove that field from the DT.
>
> The common clock bindings have fixed-factor-clock for handling dividers,
> so I believe you should be able to use that.
>
> You mentioned that the counter was a block external to the sniffer. Does
> it have any configuration interface (e.g. to reset the counter)? We may
> need to model it in the DT if so (and describe the clock as feeding into
> it rather than into the sniffer).
>

The sniffer module is designed so that it receives a Gray encoded
timestamp from another module of the SoC that it is integrated in.
The first integration that we have is in the IMG Pistachio SoC.
There the timestamp counter is part of the Event Timer module
and its source is one of the system clocks of the chip (configurable)
That module will eventually have it's own device-tree node when a
driver becomes available for it.

The 'tstamp' clock given in the sniffer DT node should be such
that when it is enabled it will start the counter and its parent clock,
so that it can start counting.

> Thanks,
> Mark.
>

Stathis
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Wed, 26 Jul 2017 19:05:47 +0200
Message-ID: <355b90b3-97ce-1057-6617-d5d709449c48@hartkopp.net>
References: <20170724230521.1436-1-fcooper@ti.com>
 <20170724230521.1436-3-fcooper@ti.com> <20170726164124.GL12049@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de, robh+dt@kernel.org,
        quentin.schulz@free-electrons.com, dev.kurt@vandijck-laurijssen.be,
        sergei.shtylyov@cogentembedded.com
To: Andrew Lunn <andrew@lunn.ch>, Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726164124.GL12049@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/26/2017 06:41 PM, Andrew Lunn wrote:
> On Mon, Jul 24, 2017 at 06:05:19PM -0500, Franklin S Cooper Jr wrote:

>> +
>> +Optional:
>> + max-arbitration-speed: a positive non 0 value that determines the max
>> +			speed that CAN can run in non CAN-FD mode or during the
>> +			arbitration phase in CAN-FD mode.
>
> Hi Franklin
>
> Since this and the next property are optional, it is good to document
> what happens when they are not in the DT blob. Also document what 0
> means.
>
>> +
>> + max-data-speed:	a positive non 0 value that determines the max data rate
>> +			that can be used in CAN-FD mode. A value of -1 implies
>> +			CAN-FD is not supported by the transceiver.
>
> -1 is ugly. I think it would be better to have a missing
> max-data-speed property indicate that CAN-FD is not supported.

Thanks Andrew! I had the same feeling about '-1' :-)

> And
> maybe put 'fd' into the property name.

Good point. In fact the common naming to set bitrates for CAN(FD) 
controllers are 'bitrate' and 'data bitrate'.

'speed' is not really a good word for that.

Finally, @Franklin:

A CAN transceiver is limited in bandwidth. But you only have one RX and 
one TX line between the CAN controller and the CAN transceiver. The 
transceiver does not know about CAN FD - it has just a physical(!) layer 
with a limited bandwidth. This is ONE limitation.

So I tend to specify only ONE 'max-bitrate' property for the 
fixed-transceiver binding.

The fact whether the CAN controller is CAN FD capable or not is provided 
by the netlink configuration interface for CAN controllers.

Regards,
Oliver

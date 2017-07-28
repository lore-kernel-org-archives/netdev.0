From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Fri, 28 Jul 2017 13:53:18 -0500
Message-ID: <80c167a2-7eb5-8076-04fc-0989981a523d@ti.com>
References: <20170728130231.GA10680@airbook.vandijck-laurijssen.be>
 <c7d4c364-1ed9-ca73-2571-d04297ac3788@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        Andrew Lunn <andrew@lunn.ch>, <linux-kernel@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-can@vger.kernel.org>, <wg@grandegger.com>,
        <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <sergei.shtylyov@cogentembedded.com>,
        <dev.kurt@vandijck-laurijssen.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c7d4c364-1ed9-ca73-2571-d04297ac3788@hartkopp.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/28/2017 01:33 PM, Oliver Hartkopp wrote:
> Hi Kurt,
> 
> On 07/28/2017 03:02 PM, Kurt Van Dijck wrote:
> 
>>>> The word 'max-arbitration-bitrate' makes the difference very clear.
>>>
>>> I think you are mixing up ISO layer 1 and ISO layer 2.
>>
>> In order to provide higher data throughput without putting extra limits
>> on transceiver & wire, the requirement for the round-trip delay to be
>> within 1 bittime has been eliminated, but only for the data phase when
>> arbitration is over.
>> So layer 2 (CAN FD) has been adapted to circumvent the layer 1
>> (transceiver + wire) limitations.
>>
>> In fact, the round-trip delay requirement never actually did matter for
>> plain CAN during data bits either. CAN FD just makes use of that,
>> but is therefore incompatible on the wire.
>>
>> I forgot the precise wording, but this is the principle that Bosch
>> explained on the CAN conference in Nurnberg several years ago, or at
>> least this is how I remembered it :-)
> 
> I just checked an example for a CAN FD qualified transceiver
> 
> http://www.nxp.com/products/automotive-products/energy-power-management/can-transceivers/high-speed-can-transceiver-with-standby-mode:TJA1044
> 
> 
> where it states:
> 
> The TJA1044T is specified for data rates up to 1 Mbit/s. Pending the
> release of ISO11898-2:2016 including CAN FD and SAE-J2284-4/5,
> additional timing parameters defining loop delay symmetry are specified
> for the TJA1044GT and TJA1044GTK. This implementation enables reliable
> communication in the CAN FD fast phase at data rates up to 5 Mbit/s.
> 
> and
> 
> TJA1044GT/TJA1044GTK
> 
> - Timing guaranteed for data rates up to 5 Mbit/s
> - Improved TXD to RXD propagation delay of 210 ns
> 
>> I haven't followed the developments of transceivers, but with the above
>> principle in mind, it's obvious that any transceiver allows higher
>> bitrates during the data segment because the TX-to-RX line delay must
>> not scale with the bitrate.
>> In reality, maybe not all transceivers will mention this in their
>> datasheet.
>>
>> So whether you call it 'max-arbitration-bitrate' & 'max-data-bitrate'
>> or 'max-bitrate' & 'max-data-bitrate' does not really matter (I prefer
>> 1st) but you will one day need 2 bitrates.
> 
> The question to me is whether it is right option to specify two bitrates
> OR to specify one maximum bitrate and provide a property that a CAN FD
> capable propagation delay is available.
> 
> E.g.
> 
>     max-bitrate
>     max-data-bitrate
> 
> or
> 
>     max-bitrate
>     canfd-capable    // CAN FD capable propagation delay available
> 
> 
> I assume the optimized propagation delay is 'always on' as the
> transceiver is not able to detect which kind of bits it is processing.
> That's why I think providing two bitrates leads to a wrong view on the
> transceiver.

I agree with this.

The transceiver is an analog device that needs to support faster
switching frequency (FETs) including minimizing delay to support CAN-FD
ie higher bitrate. From the transceiver perspective the bits for
"arbitration" and "data" look exactly the same. Since it can't
differentiate between the two (at the physical layer) then the actual
limit isn't specific to which part/type of the CAN message is being
sent. Rather its just a single overall max bitrate limit.

> 
> Regards,
> Oliver
> 

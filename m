From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Mon, 31 Jul 2017 19:03:38 +0200
Message-ID: <91879489-87de-21b9-0227-650c0001e6a3@hartkopp.net>
References: <20170728130231.GA10680@airbook.vandijck-laurijssen.be>
 <c7d4c364-1ed9-ca73-2571-d04297ac3788@hartkopp.net>
 <80c167a2-7eb5-8076-04fc-0989981a523d@ti.com>
 <20170728194143.GA10599@airbook.vandijck-laurijssen.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Franklin S Cooper Jr <fcooper@ti.com>,
        Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-can@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
        robh+dt@kernel.org, quentin.schulz@free-electrons.com,
        sergei.shtylyov@cogentembedded.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170728194143.GA10599@airbook.vandijck-laurijssen.be>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kurt,

On 07/28/2017 09:41 PM, Kurt Van Dijck wrote:

>> The transceiver is an analog device that needs to support faster
>> switching frequency (FETs) including minimizing delay to support CAN-FD
>> ie higher bitrate. From the transceiver perspective the bits for
>> "arbitration" and "data" look exactly the same. Since it can't
>> differentiate between the two (at the physical layer) then the actual
>> limit isn't specific to which part/type of the CAN message is being
>> sent. Rather its just a single overall max bitrate limit.
> 
> I must disagree here.
> The transceiver is an analog device that performs 2 functions:
> propagate tx bits to CAN wire, and propagate CAN wire state
> (dominant/recesive) to rx bits.
> 
> I'll rephrase the above explanation to fit your argument:
> During arbitration, both directions are required, and needs to propagate
> within 1 bit time. The transceiver doesn't know, it just performs to
> best effort.
> During data, the round-trip timing requirement of layer2 is relaxed.
> The transceiver still doesn't know, it still performs to best effort.
> Due to the relaxed round-trip timing requirement, the same transceiver
> can suddenly allow higher bitrates. The transceiver didn't change, the
> requirement did change.
> This is what I meant earlier with "layer2 has been adapted to circumvent
> layer1 limitations"
> 
> Was I successfull in transcoding my thoughts onto email :-) ?

Yes. But it's not relevant.

I talked to our CAN transceiver & CAN physical layer specialist who was 
involved in the ISO activities too.

We just need ONE value: max-bitrate

The CAN transceiver is qualified to provide this bitrate. That's it.
There's nothing special with the arbitration bitrate - we don't even 
need to outline any CAN FD capability.

The other things like 'loop delay compensation' are done in the CAN 
controller. The better the transceiver get's the bits 'in shape' the 
higher it can be qualified. But from the SoC/Controller/Linux view we 
only need the max-bitrate value to double check with the CAN controllers 
bitrate configuration request (which was Franklins intention).

Best regards,
Oliver

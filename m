From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: Re: CAN-FD Transceiver Limitations
Date: Thu, 29 Jun 2017 11:36:59 -0500
Message-ID: <c0d3d772-6939-d22c-b954-3ba6486a9ede@ti.com>
References: <de1f6343-4b28-4a5f-c6df-4e54c09fcce2@ti.com>
 <20170629142142.GF9244@lunn.ch> <5d4f2bcf-bd0f-4fa1-5d5a-d7b4a83cbc5e@ti.com>
 <20170629154139.GC13221@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>,
        <devicetree@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:54321 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751941AbdF2QiE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 12:38:04 -0400
In-Reply-To: <20170629154139.GC13221@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+device tree mailing list

Hi Andrew
On 06/29/2017 10:41 AM, Andrew Lunn wrote:
>> Transceivers for CAN are not apart of any model. Traditional CAN didn't
>> have a problem because all transceivers from my understanding supported
>> the maximum speed of 1 Mbps defined by the spec. However, with the
>> introduction of CAN Flexible Datarate mode it seems that for
>> transceivers that supported CAN-FD the maximum supported speeds vary.
> 
> So transceivers are dumb devices, nothing to configure, so no need to
> have a driver for them.
> 
>> Now that I think of it
>> you also can't determine if the transceiver supports CAN-FD in the first
>> place. IP that supports CAN-FD is backwards compatible with standard
>> CAN. Therefore, its feasible that you may even use a transceiver that
>> doesn't support CAN-FD. So I would think something like the below would
>> be needed.
>>
>> mcan@0 {
>> 	...
>> 	fixed-transceiver {
>> 	      max-canfd-speed = <2000>
>> 	};
>> 	...
>> };
> 
> Are there likely to be other transceiver properties? Adding a subnode
> may not make sense if this is going to be the only property.
> 
> Also, 2KHz is not very fast :-)
> 
> Taking a quick look in Documentation/devicetree/bindings/net/can, it
> seems a bit of a wild west. No standardization, no central binding
> which CAN drivers are expected to support, etc. This sounds like a
> generic problem, not an mcan problem. So document this property
> centrally, implement the parsing of it centrally, etc, to encourage
> other CAN drivers to use it, rather than re-invent the wheel.

As of now its the only property that I think is needed. In general from
past experience and threads it seems that people are fairly adamant
about having DT mimic hardware as closely as possible. So since from a
hardware perspective the transceiver is an external device that is
connected to the CAN IP it would make sense for a subnode to be used to
model it. But either way works for me. If the device tree folks do not
care for subnode to be created then I can just add a property.

Also I agree that attempting to make this optional property/subnode
generic to all of CAN would be preferable. Another not sure if its
feasible yet without standardization being first forced across all CAN
drivers.


> 
> 	   Andrew
> 

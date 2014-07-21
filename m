From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: mvebu: Can we make the orion-mdio clock a requirement?
Date: Mon, 21 Jul 2014 22:12:45 +0200
Message-ID: <53CD743D.9080700@gmail.com>
References: <20140721190614.GB20027@arch.cereza> <20140721212818.2d4920c4@free-electrons.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:49251 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601AbaGUUNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 16:13:21 -0400
Received: by mail-we0-f170.google.com with SMTP id w62so8014841wes.1
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 13:13:17 -0700 (PDT)
In-Reply-To: <20140721212818.2d4920c4@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2014 09:28 PM, Thomas Petazzoni wrote:
> On Mon, 21 Jul 2014 16:06:15 -0300, Ezequiel Garcia wrote:
>> Currently the mvmdio driver does not require a clock to be declared,
>> and instead this is optional.
>>
>> However (almost) all the platforms that currently use it, i.e. the
>> Armada, Kirkwood and Dove SoCs, require some clock to be enabled before
>> the MDIO registers can be accessed.
>>
>> The Orion5x SoC doesn't declare any clock for neither the ethernet node,
>> nor the MDIO node. Is that correct?
> 
> There are no gatable clocks on Orion5x, so unless the driver really
> wants a clock, there's no hard requirement to give a clock reference.
> 
>> Do you think we could make the clock a required property in the mvmdio
>> devicetree node? How would that behave in the non-DT case?
> 
> I don't think the mvmdio driver is used in non-DT contexts.
> 
> However, yes, I tend to agree, making the clock mandatory would
> probably be a good thing.

We can always pass TCLK on Orion5x if there is a need for a mandatory
clock. Anyway, IIRC clock framework should now properly return
-EPROPEDEFER only if there is a clock property set. If there is none,
the error is different and can be catched on Orion5x.

Sebastian

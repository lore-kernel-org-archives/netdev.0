From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: proper initialization for Kirkwood
 SoCs
Date: Wed, 22 May 2013 23:02:05 +0200
Message-ID: <519D324D.6070903@gmail.com>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369253042-15082-2-git-send-email-sebastian.hesselbarth@gmail.com> <20130522201607.GA18823@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130522201607.GA18823@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2013 10:16 PM, Jason Gunthorpe wrote:
> On Wed, May 22, 2013 at 10:04:02PM +0200, Sebastian Hesselbarth wrote:
>> Ethernet controllers found on Kirkwood SoCs not only suffer from loosing
>> MAC address register contents on clock gating but also some important
>> registers are reset to values that would break ethernet. This patch
>
> FWIW, we found that the bootloader has to write to PSC1, the driver
> doesn't work with the power on/reset value of the register. So I think
> it is safe to assume that all kirkwood bootloaders alter the value.

It is safe to assume the bootloader alters it, but that modification is
lost when clocks get gated. I assume on clock ungate, the controller is
reset. Saying this, I will double check Dove's reset value but looks 
like reset mess has been fixed in that later SoC.

> Our systems write the value 0x00638488 to PSC1.
>
> I looked at patching mv643xx_eth, but ran into the same complexity you
> did, it isn't clear what variants of this IP block have the
> register/etc.

For Orion SoCs it is quite clear to me, with Gregory Clement and Thomas
Petazzoni we could also confirm if it does any harm there if we
unconditionally clear it. But for PPC system controllers I have no
idea...

>> +	/* Kirkwood resets some registers on gated clocks. Especially
>> +	 * CLK125_BYPASS_EN must be cleared but is not available on
>> +	 * all other SoCs/System Controllers using this driver.
>> +	 */
>> +	if (of_machine_is_compatible("marvell,kirkwood"))
>> +		wrlp(mp, PORT_SERIAL_CONTROL1,
>> +		     rdlp(mp, PORT_SERIAL_CONTROL1)&  ~CLK125_BYPASS_EN);
>
> of_machine_is_compatible seems heavy handed, I would expect this to be
> based on the compatible string of the ethernet node itself, not the
> machine??

I have no strong opinion about checking the machine compatible or have
an extra compatible string for Kirkwood ethernet. Both would work fine
and are checked once upon probe anyway.

Sebastian

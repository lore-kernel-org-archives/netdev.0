From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH net 1/2] net: cadence: macb: Disable USRIO register on
 some platforms
Date: Tue, 8 Dec 2015 10:21:35 +0100
Message-ID: <CAA3gFWtDiza1V3_eM84JxseHRDJMH_NF4Rx=-dOPD-Usp=pVNA@mail.gmail.com>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
	<1449485914-12883-2-git-send-email-narmstrong@baylibre.com>
	<20151207193215.GI29051@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Harini Katakam <harini.katakam@xilinx.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	devicetree@vger.kernel.org
To: Josh Cartwright <joshc@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151207193215.GI29051@jcartwri.amer.corp.natinst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Josh,

2015-12-07 20:32 GMT+01:00 Josh Cartwright <joshc@ni.com>:
> On Mon, Dec 07, 2015 at 11:58:33AM +0100, Neil Armstrong wrote:
>> On some platforms, the macb integration does not use the USRIO
>> register to configure the (R)MII port and clocks.
>> When the register is not implemented and the MACB error signal
>> is connected to the bus error, reading or writing to the USRIO
>> register can trigger some Imprecise External Aborts on ARM platforms.
>> ---
>
> Does this make sense to even be a separate bool device tree property?
>
> This sort of configuration is typically done by:
>    1. Creating a new 'caps' bit; relevant codepaths check that bit
>    2. Creating a new "compatible" string for your platform's macb
>       instance
>    3. Creating a new 'struct macb_config' instance for your platform,
>       setting any relevant caps bits when it is selected.
>
>   Josh

I see the point, but according to the User Guide :
>User I/O Register
> The MACB design provides up to 16 inputs and 16 outputs,
> for which the state of the I/O may
> be read or set under the control of the processor interface.
> If the user I/O is disabled as a configuration option, this address space is defined
> as reserved, and hence will be a read-only register of value 0x0.

On the design I worked on, the macb_user_* signals were commented,
thus disabling this register.

The implementation is not mandatory, and the "generic" macb compatible
"cdns,macb" should disable
usage of USRIO register by default and be only used for platform
specific macb instances...

Is it OK if I add a new 'caps' bit and use it for the "generic" macb instance ?

For the device tree property, it should be safe to have the generic
instances of macb and gem to
rely on these properties instead of hardcoded instances.
(it's the biggest aim of device tree, no ? no more hardcoded 'caps' bit ?)
The "no-usrio" and other should eventually map 'caps' bits along the
generic instances.

Neil

From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Tue, 30 Sep 2014 17:02:41 +0300
Message-ID: <542AB801.6050805@ti.com>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-3-git-send-email-rogerq@ti.com> <20140930132650.GN1325@katana> <542AB400.6080608@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wg@grandegger.com>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <542AB400.6080608@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/30/2014 04:45 PM, Marc Kleine-Budde wrote:
> On 09/30/2014 03:26 PM, Wolfram Sang wrote:
>> On Tue, Sep 09, 2014 at 05:31:09PM +0300, Roger Quadros wrote:
>>> Some TI SoCs like DRA7 have a RAMINIT register specification
>>> different from the other AMxx SoCs and as expected by the
>>> existing driver.
>>>
>>> To add more insanity, this register is shared with other
>>> IPs like DSS, PCIe and PWM.
>>>
>>> Provides a more generic mechanism to specify the RAMINIT
>>> register location and START/DONE bit position and use the
>>> syscon/regmap framework to access the register.
>>>
>>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>>> ---
>>>  .../devicetree/bindings/net/can/c_can.txt          |   7 ++
>>>  drivers/net/can/c_can/c_can.h                      |  11 ++-
>>>  drivers/net/can/c_can/c_can_platform.c             | 109 +++++++++++++++------
>>>  3 files changed, 95 insertions(+), 32 deletions(-)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
>>> index 8f1ae81..e12d1a1 100644
>>> --- a/Documentation/devicetree/bindings/net/can/c_can.txt
>>> +++ b/Documentation/devicetree/bindings/net/can/c_can.txt
>>> @@ -13,6 +13,13 @@ Optional properties:
>>>  - ti,hwmods		: Must be "d_can<n>" or "c_can<n>", n being the
>>>  			  instance number
>>>  
>>> +- ti,raminit-syscon	: Handle to system control region that contains the
>>> +			  RAMINIT register. If specified, the second memory resource
>>> +			  in the reg property must index into the RAMINIT
>>> +			  register within the syscon region
>>
>> There seems to be a simple "syscon" property these days.
>>
>>> +- ti,raminit-start-bit	: Bit posistion of START bit in the RAMINIT register
>>> +- ti,raminit-done-bit	: Bit position of DONE bit in the RAMINIT register
>>
>> This should not be encoded in DT! This is not describing hardware setup.
>> The driver should know where the bits are for the syscon phandle,
>> depending on which SoC it runs...
> 
> Is the register shared by more than one core? If so the information has
> to go somewhere. Using an alias in the DT is probably the wrong approach.

In case of the DRA7xx Soc, this syscon register is shared by multiple cores. (CAN, Display, etc), sigh!!
For AM335x and AM43xx SoCs, the register is used only for DCAN. but shared by 2 DCAN instances.

Shouldn't the information for the CAN specific bits lie in the CAN driver?

cheers,
-roger

From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: fec: add post PHY reset delay DT property
Date: Wed, 31 May 2017 18:52:55 -0700
Message-ID: <621b21da-e152-dead-de0f-af17e7c55a38@gmail.com>
References: <20170523094808.11102-1-quentin.schulz@free-electrons.com>
 <20170531164416.ka3hk6a2lybrlngd@rob-hp-laptop>
 <AM4PR0401MB226073F4A403F31FA0FF2BE0FFF60@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>
To: Andy Duan <fugang.duan@nxp.com>, Rob Herring <robh@kernel.org>,
        Quentin Schulz <quentin.schulz@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM4PR0401MB226073F4A403F31FA0FF2BE0FFF60@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 05/31/17 à 18:39, Andy Duan a écrit :
> From: Rob Herring <robh@kernel.org> Sent: Thursday, June 01, 2017 12:44 AM
>> On Tue, May 23, 2017 at 11:48:08AM +0200, Quentin Schulz wrote:
>>> Some PHY require to wait for a bit after the reset GPIO has been
>>> toggled. This adds support for the DT property `phy-reset-post-delay`
>>> which gives the delay in milliseconds to wait after reset.
>>>
>>> If the DT property is not given, no delay is observed. Post reset
>>> delay greater than 1000ms are invalid.
>>>
>>> Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>
>>> ---
>>>
>>> v2:
>>>   - return -EINVAL when phy-reset-post-delay is greater than 1000ms
>>>   instead of defaulting to 1ms,
>>>   - remove `default to 1ms` when phy-reset-post-delay > 1000Ms from DT
>>>   binding doc and commit log,
>>>   - move phy-reset-post-delay property reading before
>>>   devm_gpio_request_one(),
>>>
>>>  Documentation/devicetree/bindings/net/fsl-fec.txt |  4 ++++
>>>  drivers/net/ethernet/freescale/fec_main.c         | 16 +++++++++++++++-
>>>  2 files changed, 19 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt
>>> b/Documentation/devicetree/bindings/net/fsl-fec.txt
>>> index a1e3693cca16..6f55bdd52f8a 100644
>>> --- a/Documentation/devicetree/bindings/net/fsl-fec.txt
>>> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
>>> @@ -15,6 +15,10 @@ Optional properties:
>>>  - phy-reset-active-high : If present then the reset sequence using the GPIO
>>>    specified in the "phy-reset-gpios" property is reversed (H=reset state,
>>>    L=operation state).
>>> +- phy-reset-post-delay : Post reset delay in milliseconds. If present
>>> +then
>>
>> This needs unit suffix minimally. It should also have a vendor prefix or be
>> made generic.
>>
>> But really, this is a property of the phy and should be in the phy node as
>> should phy-reset-gpios, phy-reset-active-high, phy-supply, etc.
>>
> Yes, it is better to make it general.
> Last year, Uwe Kleine-König's patch "Commit da47b4572056 ("phy: add support for a reset-gpio specification")" did this, but it was reverted by commit 948350140ef0 (Revert "phy: add support for a reset-gpio specification").  And in all phy device driver, only at803x.c add the gpio reset in currently. 

Getting the binding correct does not prevent us from later moving this
reset code into PHYLIB where it's appropriate. In fact; a correct and
generic binding proposed for FEC here could be used as a basis for all
other MAC and PHY drivers.
-- 
Florian

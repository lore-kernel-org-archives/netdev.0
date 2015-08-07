From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 2/2] net, thunder, bgx: Add support for ACPI binding.
Date: Fri, 7 Aug 2015 09:40:41 -0700
Message-ID: <55C4DF89.9060502@caviumnetworks.com>
References: <1438907590-29649-1-git-send-email-ddaney.cavm@gmail.com> <1438907590-29649-3-git-send-email-ddaney.cavm@gmail.com> <55C467A0.4020601@linaro.org> <20150807104320.GQ1820@rric.localhost> <55C48DF9.70406@linaro.org> <20150807115622.GS4914@rric.localhost> <55C4A7AC.1080902@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <robert.richter@caviumnetworks.com>,
	David Daney <ddaney.cavm@gmail.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-mips@linux-mips.org>, Sunil Goutham <sgoutham@cavium.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>, David Daney <david.daney@cavium.com>
To: Tomasz Nowicki <tomasz.nowicki@linaro.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <55C4A7AC.1080902@linaro.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/07/2015 05:42 AM, Tomasz Nowicki wrote:
> On 07.08.2015 13:56, Robert Richter wrote:
>> On 07.08.15 12:52:41, Tomasz Nowicki wrote:
[...]

>>>>
>>>> I would not pollute bgx_probe() with acpi and dt specifics, and instead
>>>> keep bgx_init_phy(). The typical design pattern for this is:
>>>>
>>>> static int bgx_init_phy(struct bgx *bgx)
>>>> {
>>>> #ifdef CONFIG_ACPI
>>>>          if (!acpi_disabled)
>>>>                  return bgx_init_acpi_phy(bgx);
>>>> #endif
>>>>          return bgx_init_of_phy(bgx);
>>>> }
>>>>
>>>> This adds acpi runtime detection (acpi=no), does not call dt code in
>>>> case of acpi, and saves the #else for bgx_init_acpi_phy().
>>>>
>>>
>>> I am fine with keeping it in bgx_init_phy(), however we can drop there
>>> #ifdefs since both of bgx_init_{acpi,of}_phy calls have empty stub
>>> for !ACPI
>>> and !OF case. Like that:
>>>
>>> static int bgx_init_phy(struct bgx *bgx)
>>> {
>>>
>>>          if (!acpi_disabled)
>>>                  return bgx_init_acpi_phy(bgx);
>>>     else
>>>              return bgx_init_of_phy(bgx);
>>> }
>>
>> As said, keeping it in #ifdefs makes the empty stub function for !acpi
>> obsolete, which makes the code smaller and better readable. This style
>> is common practice in the kernel. Apart from that, the 'else' should
>> be dropped as it is useless.
>>
>
> I would't say the code is better readable (bgx_init_of_phy has still two
> stubs) but this is just cosmetic, my point was to use run time detection
> using acpi_disabled.
>

Thanks Tomasz and Robert for the input.  Because of this, it seems that 
another version of the patch will be necessary.  In the interests of 
code clarity and asthetics, we will go with the code without the 
#ifdefs, and rely on the compiler to optimize away any dead code.

David Daney

> Tomasz


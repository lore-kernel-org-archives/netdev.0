From: Hanjun Guo <hanjun.guo@linaro.org>
Subject: Re: [PATCH v2 0/2] net: thunder: Add ACPI support.
Date: Thu, 13 Aug 2015 16:34:13 +0800
Message-ID: <55CC5685.4000807@linaro.org>
References: <1439254717-2875-1-git-send-email-ddaney.cavm@gmail.com> <20150811.114908.1384923604512568161.davem@davemloft.net> <55CA5567.9010002@caviumnetworks.com> <20150812152337.GB5393@e104818-lin.cambridge.arm.com> <55CB67E4.8030001@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, linux-mips@linux-mips.org,
	david.daney@cavium.com, netdev@vger.kernel.org, rafael@kernel.org,
	linux-kernel@vger.kernel.org, tomasz.nowicki@linaro.org,
	rrichter@cavium.com, linux-acpi@vger.kernel.org,
	ddaney.cavm@gmail.com, sgoutham@cavium.com,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: David Daney <ddaney@caviumnetworks.com>,
	Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55CB67E4.8030001@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/12/2015 11:36 PM, David Daney wrote:
> On 08/12/2015 08:23 AM, Catalin Marinas wrote:
>> On Tue, Aug 11, 2015 at 01:04:55PM -0700, David Daney wrote:
>>> On 08/11/2015 11:49 AM, David Miller wrote:
>>>> From: David Daney <ddaney.cavm@gmail.com>
>>>> Date: Mon, 10 Aug 2015 17:58:35 -0700
>>>>
>>>>> Change from v1:  Drop PHY binding part, use fwnode_property* APIs.
>>>>>
>>>>> The first patch (1/2) rearranges the existing code a little with no
>>>>> functional change to get ready for the second.  The second (2/2) does
>>>>> the actual work of adding support to extract the needed information
>>>> >from the ACPI tables.
>>>>
>>>> Series applied.
>>>
>>> Thank you very much.
>>>
>>>> In the future it might be better structured to try and get the OF
>>>> node, and if that fails then try and use the ACPI method to obtain
>>>> these values.
>>>
>>> Our current approach, as you can see in the patch, is the opposite.
>>> If ACPI
>>> is being used, prefer that over the OF device tree.
>>>
>>> You seem to be recommending precedence for OF.  It should be consistent
>>> across all drivers/sub-systems, so do you really think that OF before
>>> ACPI
>>> is the way to go?
>>
>> On arm64 (unless you use a vendor kernel), DT takes precedence over ACPI
>> if both arm provided to the kernel (and it's a fair assumption given
>> that ACPI on ARM is still in the early days). You could also force ACPI
>> with acpi=force on the kernel cmd line and the arch code will not
>> unflatten the DT even if it is provided, therefore is_of_node(fwnode)
>> returning false.

Yes. on the other hand, if no DT is provided, will try ACPI even
if no acpi=force on the kernel cmd line.

>>
>> I haven't looked at your driver in detail but something like AMD's
>> xgbe_probe() uses a single function for both DT and ACPI with
>> device_property_read_*() functions getting the information from the
>> correct place in either case. The ACPI vs DT precedence is handled by
>> the arch boot code, we never mix the two and confuse the drivers.
>>
>
> My long term plan is to create something like
> firmware_get_mac_address(), that would encapsulate  of_get_mac_address()
> and the ACPI equivalent.
>
> Same for firmware_phy_find_device().

I'm very keen on seeing that happens :)

Thanks
Hanjun

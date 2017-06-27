From: Scott Branden <scott.branden@broadcom.com>
Subject: Re: [PATCH v1 1/2] dt-binding: ptp: add bindings document for dte
 based ptp clock
Date: Mon, 26 Jun 2017 22:10:57 -0700
Message-ID: <7bb41c9b-20d8-6003-8a0f-b09f0071ed71@broadcom.com>
References: <1497299161-6458-1-git-send-email-arun.parameswaran@broadcom.com>
 <1497299161-6458-2-git-send-email-arun.parameswaran@broadcom.com>
 <20170618140449.aek7vag22i5lnbhl@rob-hp-laptop>
 <74b85a32-63c5-b7c5-47a2-831504be318e@broadcom.com>
 <CAL_JsqKddhWMXEaoxt=3_d+-STFH-OataxSgnnj9Q4A0Eqqwxg@mail.gmail.com>
 <1abad545-ee20-e047-8cb6-b130ad037213@broadcom.com>
 <86c2b69e-a3f4-69d8-63c3-d3e73b4bde54@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arun Parameswaran <arun.parameswaran@broadcom.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        "bcm-kernel-feedback-list@broadcom.com"
        <bcm-kernel-feedback-list@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36860 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751473AbdF0FLD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 01:11:03 -0400
Received: by mail-wm0-f53.google.com with SMTP id 62so14068382wmw.1
        for <netdev@vger.kernel.org>; Mon, 26 Jun 2017 22:11:03 -0700 (PDT)
In-Reply-To: <86c2b69e-a3f4-69d8-63c3-d3e73b4bde54@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob/Florian,

Thanks for input but still don't see any need for SoC specific
compatible stings.  IP revision specific yes.

On 17-06-22 06:04 PM, Florian Fainelli wrote:
> On 06/22/2017 05:42 PM, Scott Branden wrote:
>>
>> On 17-06-21 08:19 PM, Rob Herring wrote:
>>> On Tue, Jun 20, 2017 at 3:48 PM, Scott Branden
>>> <scott.branden@broadcom.com> wrote:
>>>> Hi Rob,
>>>>
>>>>
>>>> On 17-06-18 07:04 AM, Rob Herring wrote:
>>>>> On Mon, Jun 12, 2017 at 01:26:00PM -0700, Arun Parameswaran wrote:
>>>>>> Add device tree binding documentation for the Broadcom DTE
>>>>>> PTP clock driver.
>>>>>>
>>>>>> Signed-off-by: Arun Parameswaran <arun.parameswaran@broadcom.com>
>>>>>> ---
>>>>>>     Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt | 13
>>>>>> +++++++++++++
>>>>>>     1 file changed, 13 insertions(+)
>>>>>>     create mode 100644
>>>>>> Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>>>>>>
>>>>>> diff --git a/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>>>>>> b/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>>>>>> new file mode 100644
>>>>>> index 0000000..07590bc
>>>>>> --- /dev/null
>>>>>> +++ b/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>>>>>> @@ -0,0 +1,13 @@
>>>>>> +* Broadcom Digital Timing Engine(DTE) based PTP clock driver
>>>>> Bindings describe h/w, not drivers.
>>>>>
>>>>>> +
>>>>>> +Required properties:
>>>>>> +- compatible: should be "brcm,ptp-dte"
>>>>> Looks too generic. You need SoC specific compatible strings.
>>>> Rob, could you please help me understand the use of adding SoC specific
>>>> compatible strings.
>>>> I still don't get it.
>>>>
>>>> It's my understanding that the SoC compatibility string is to future
>>>> proof
>>>> against bugs/incompatibilities
>>>> between different versions of the hardware block due to integration
>>>> issues
>>>> or any other reason.
>>>> You can then compare in your driver because the strings were already
>>>> used in
>>>> the dtb.
>>>>
>>>> That would make sense if you can't already differentiate what SoC you
>>>> are
>>>> running on.
>>>> But the SoC is already specified in the root of the device tree in the
>>>> compatible string?
>>>> Why can't you just use of_machine_is_compatible inside your driver when
>>>> needed?
>>> Use of of_machine_is_compatible in drivers will result in the same
>>> mess we had with machine_is_X defines pre-DT. It practically
>>> guarantees that you must update the driver for a new SoC (with
>>> fallback compatibles you don't). Plus the matching logic for
>>> of_machine_is_compatible is open coded logic in every driver which is
>>> worse IMO than having a standard match table.
>> I don't understand what you mean by fallback compatible then.
>>
>> Let's say I have 3 SoCs that each contain the same ip block.
>> You want us to add a fallback compatibility per SoC, is that correct?
> I think Rob meant a fallback compatibility for the particular block.
> E.g: brcm,iproc-ptp is the fallback compatible string, but in your
> SoC-specific DTS, you would have at least:
>
> compatible = "brcm,cygnus-ptp", "brcm,iproc-ptp";
>
> Where cygnus-ptp is more specific than iproc-ptp
>> Then, if there is a workaround discovered in a particular SoC the driver
>> can be updated in the future without changing the dtb.
>>
>> Then, the block gets added to a 4th SoC.
>> You want us to another new compatibility string for the new SoC?
>> If the new SoC has a bug then the driver has to be updated whether it is
>> in uses the fallback compatible or machine_is_compatible string.
>>
>> There is no difference in amount of code added to a driver when a new
>> SoC is introduced into the system that has bugs that need to be handled
>> by the driver.
>>
>> The difference is in your recommendation we need to go through all the
>> drivers used by the new SoC and add fallback compatibility strings.
> Not really, the fallback is what the driver should be matching by
> default (hence the name fallback) and if and only if you need to have a
> SoC-specific behavior in your driver (because of bugs, or slight
> differences) would you be matching this SoC-specific compatible string
> to capture that and key the driver behavior based off that.
>
>> Then, we have to modify all the devicetree documentation for all the
>> drivers.  Then, we have to ensure that all dts files populate this new
>> fallback string (even if it is unused).  We don't see the benefit in
>> doing any of that.  Using machine_is_compatible and having less
>> compatibility strings to deal appears much cleaner and more foolproof
>> for all situations.
> When you introduce a new SoC, you would update all the bindings for the
> devices (not drivers) that are susceptible to be used by this SoC. If
> all goes well, your SoC has little bugs, and your drivers don't even
> need to see an update because they are already matching the fallback
> compatible string.
>
> That's what I understand from the suggestion but I may be totally off
> rails here.
In this particular case, the IP is integrated within and outside a 
family of SoCs
(the exact same block is in Capri for example).
The only fallback compatablity string that makes sense is "brcm, 
dte-ptp-v1".
When we integrate a new version of this IP we would add "brcm, dte-ptp-v2".

Rob, I still see no need to define any other compatablity strings.

Everything else can be handled with machine_is_compatible
with the exact same amount of code change to the driver?
Adding the additional strings simply
adds a need to change documentation and changes to dts that are otherwise
completely unnecessary.  machine_is_compatible appears to be the cleaner
and simpler solution?

Regards,
  Scott

From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v1 1/2] dt-binding: ptp: add bindings document for dte
 based ptp clock
Date: Wed, 21 Jun 2017 22:19:10 -0500
Message-ID: <CAL_JsqKddhWMXEaoxt=3_d+-STFH-OataxSgnnj9Q4A0Eqqwxg@mail.gmail.com>
References: <1497299161-6458-1-git-send-email-arun.parameswaran@broadcom.com>
 <1497299161-6458-2-git-send-email-arun.parameswaran@broadcom.com>
 <20170618140449.aek7vag22i5lnbhl@rob-hp-laptop> <74b85a32-63c5-b7c5-47a2-831504be318e@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org"
        <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Scott Branden <scott.branden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <74b85a32-63c5-b7c5-47a2-831504be318e-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2017 at 3:48 PM, Scott Branden
<scott.branden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
> Hi Rob,
>
>
> On 17-06-18 07:04 AM, Rob Herring wrote:
>>
>> On Mon, Jun 12, 2017 at 01:26:00PM -0700, Arun Parameswaran wrote:
>>>
>>> Add device tree binding documentation for the Broadcom DTE
>>> PTP clock driver.
>>>
>>> Signed-off-by: Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>>> ---
>>>   Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt | 13
>>> +++++++++++++
>>>   1 file changed, 13 insertions(+)
>>>   create mode 100644
>>> Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>>>
>>> diff --git a/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>>> b/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>>> new file mode 100644
>>> index 0000000..07590bc
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>>> @@ -0,0 +1,13 @@
>>> +* Broadcom Digital Timing Engine(DTE) based PTP clock driver
>>
>> Bindings describe h/w, not drivers.
>>
>>> +
>>> +Required properties:
>>> +- compatible: should be "brcm,ptp-dte"
>>
>> Looks too generic. You need SoC specific compatible strings.
>
>
> Rob, could you please help me understand the use of adding SoC specific
> compatible strings.
> I still don't get it.
>
> It's my understanding that the SoC compatibility string is to future proof
> against bugs/incompatibilities
> between different versions of the hardware block due to integration issues
> or any other reason.
> You can then compare in your driver because the strings were already used in
> the dtb.
>
> That would make sense if you can't already differentiate what SoC you are
> running on.
> But the SoC is already specified in the root of the device tree in the
> compatible string?
> Why can't you just use of_machine_is_compatible inside your driver when
> needed?

Use of of_machine_is_compatible in drivers will result in the same
mess we had with machine_is_X defines pre-DT. It practically
guarantees that you must update the driver for a new SoC (with
fallback compatibles you don't). Plus the matching logic for
of_machine_is_compatible is open coded logic in every driver which is
worse IMO than having a standard match table.

>
> Please explain what I'm missing.  I see other drivers already following the
> of_machine_is_compatible
> approach and it makes more sense to me than adding SoC specific compatible
> strings into every
> driver.

If the IP blocks are all the same, you don't have to add them to any
drivers, just add fallback compatibles.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

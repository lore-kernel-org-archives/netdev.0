From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] DT: net: document Ethernet bindings in one place
Date: Tue, 21 Jan 2014 11:56:44 -0800
Message-ID: <CAGVrzcb3X3soJNJCE5+YSpQrr+EdycCRFkptPvBCgFg4CbGJ4Q@mail.gmail.com>
References: <201401180405.07859.sergei.shtylyov@cogentembedded.com>
 <CAL_Jsq+oa9P=rh+p-dMZyGP8TcmpX7bTnMU0ynLvFxjxFDYbRg@mail.gmail.com>
 <52DD98F7.4090202@cogentembedded.com> <CAL_JsqJXbF1-PcPHR2VP+Vi9A1aWizdsG_r3kDvRt3itXDhCGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Rob Landley <rob@landley.net>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:55179 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbaAUT5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 14:57:24 -0500
In-Reply-To: <CAL_JsqJXbF1-PcPHR2VP+Vi9A1aWizdsG_r3kDvRt3itXDhCGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/20 Rob Herring <robherring2@gmail.com>:
> On Mon, Jan 20, 2014 at 3:45 PM, Sergei Shtylyov
> <sergei.shtylyov@cogentembedded.com> wrote:
>> On 01/20/2014 05:06 PM, Rob Herring wrote:
>>
>>>> This patch is an attempt to gather the Ethernet related bindings in one
>>>> file,
>>>> like it's done in the MMC and some other subsystems. It should save the
>>>> trouble
>>>> of documenting several properties over and over in each binding document.
>>
>>
>>>> I have used the Embedded Power Architecture(TM) Platform Requirements
>>>> (ePAPR)
>>>> standard as a base for the properties description, also documenting some
>>>> ad-hoc
>>>> properties that have been introduced over time despite having direct
>>>> analogs in
>>>> ePAPR.
>>
>>
>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>>
>>>> ---
>>>> The patch is against DaveM's 'net-next.git' repo and the DaVinci EMAC
>>>> bindings
>>>> fix I've posted yesterday:
>>
>>
>>>> http://patchwork.ozlabs.org/patch/311854/
>>
>>
>> [...]
>
>>>> Index: net-next/Documentation/devicetree/bindings/net/ethernet.txt
>>>> ===================================================================
>>>> --- /dev/null
>>>> +++ net-next/Documentation/devicetree/bindings/net/ethernet.txt
>>>> @@ -0,0 +1,20 @@
>>>> +The following properties are common to the Ethernet controllers:
>>>> +
>>>> +- local-mac-address: array of 6 bytes, specifies the MAC address that
>>>> was
>>>> +  assigned to the network device;
>>>> +- mac-address: array of 6 bytes, specifies the MAC address that was last
>>>> used by
>>>> +  the boot program; should be used in cases where the MAC address
>>>> assigned to
>>>> +  the device by the boot program is different from the
>>>> "local-mac-address"
>>>> +  property;
>>>> +- max-speed: number, specifies maximum speed in Mbit/s supported by the
>>>> device;
>>>> +- phy-mode: string, operation mode of the PHY interface; supported
>>>> values are
>>>> +  "mii", "gmii", "sgmii", "tbi", "rev-mii", "rmii", "rgmii", "rgmii-id",
>>>> +  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii";
>>
>>
>>> Mark this as deprecated
>>
>>
>>    That's kind of wishful thinking at this point, as that's what the
>> majority of drivers use. I'm unsure of the reasons why that was done,
>> probably people just didn't read the proper specs...
>
> Or the spec was defined after those bindings. Deprecating does not
> matter for existing bindings. It's only defining new ones that are
> affected. I was more concerned with giving people guidance on which
> one to use for new bindings.
>
>>> in favor of phy-connection-type
>>
>>
>>    That one is only used by the oldish PowerPC 'gianfar' driver.
>>
>>
>>> so it's use does not spread.
>>
>>
>>    I'm afraid that's too late, it has spread very far, so that
>> of_get_phy_mode() handles that property, not "phy-connection-type".
>
> Uggg, I guess this is a case of a defacto standard then if the kernel
> doesn't even support it.

Maybe I forgot to CC you on patch sent to Grant only, I sent a patch a
while ago for of_get_phy_mode() to look for both "phy-mode" and
"phy-connection-type" since the former has been a Linux invention, but
the latter is ePAPR specified.

>
>>>> +- phy-connection-type: the same as "phy-mode" property (but described in
>>>> ePAPR);
>>>> +- phy-handle: phandle, specifies a reference to a node representing a
>>>> PHY
>>>> +  device (this property is described in ePAPR);
>>>> +- phy: the same as "phy-handle" property (but actually ad-hoc one).
>>
>>
>>> Mark this as deprecated in favor of phy-handle.
>>
>>
>>    Here situation is more optimistic. Quite many drivers still use
>> "phy-handle", though some use even more exotic props I didn't document here.
>
> Perhaps flagging as "Not recommended for new bindings" would be nicer wording...

Ok, so what's the deal here, can't we use phy-handle? There is
currently no infrastructure in drivers/net/ or drivers/of/ to look for
the "phy-handle" nor "phy" properties as phandles to fetch an Ethernet
PHY device tree node. If we are to provide one common place where we
want to do this, we will have to look for both properties, why can't
we mandate the use of "phy-handle" since this is the ePAPR compliant
one?

>
> Rob
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian

From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH] DT: net: document Ethernet bindings in one place
Date: Tue, 21 Jan 2014 19:30:39 -0600
Message-ID: <CAL_JsqJF4m5ny5v_G1nEaNbH3Esdw8kuz__JpiJbkF=2ciY=9g@mail.gmail.com>
References: <201401180405.07859.sergei.shtylyov@cogentembedded.com>
	<CAL_Jsq+oa9P=rh+p-dMZyGP8TcmpX7bTnMU0ynLvFxjxFDYbRg@mail.gmail.com>
	<52DD98F7.4090202@cogentembedded.com>
	<CAL_JsqJXbF1-PcPHR2VP+Vi9A1aWizdsG_r3kDvRt3itXDhCGQ@mail.gmail.com>
	<CAGVrzcb3X3soJNJCE5+YSpQrr+EdycCRFkptPvBCgFg4CbGJ4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcb3X3soJNJCE5+YSpQrr+EdycCRFkptPvBCgFg4CbGJ4Q@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 21, 2014 at 1:56 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014/1/20 Rob Herring <robherring2@gmail.com>:
>> On Mon, Jan 20, 2014 at 3:45 PM, Sergei Shtylyov
>> <sergei.shtylyov@cogentembedded.com> wrote:
>>> On 01/20/2014 05:06 PM, Rob Herring wrote:

[snip]

>>>>> +- phy-connection-type: the same as "phy-mode" property (but described in
>>>>> ePAPR);
>>>>> +- phy-handle: phandle, specifies a reference to a node representing a
>>>>> PHY
>>>>> +  device (this property is described in ePAPR);
>>>>> +- phy: the same as "phy-handle" property (but actually ad-hoc one).
>>>
>>>
>>>> Mark this as deprecated in favor of phy-handle.
>>>
>>>
>>>    Here situation is more optimistic. Quite many drivers still use
>>> "phy-handle", though some use even more exotic props I didn't document here.
>>
>> Perhaps flagging as "Not recommended for new bindings" would be nicer wording...
>
> Ok, so what's the deal here, can't we use phy-handle? There is
> currently no infrastructure in drivers/net/ or drivers/of/ to look for
> the "phy-handle" nor "phy" properties as phandles to fetch an Ethernet
> PHY device tree node. If we are to provide one common place where we
> want to do this, we will have to look for both properties, why can't
> we mandate the use of "phy-handle" since this is the ePAPR compliant
> one?

My count is 3 using "phy" and 11 using "phy-handle". Even if we
mandate phy-handle, we still have to support both properties to
maintain compatibility with existing DTs. But nothing new should use
"phy".  I'm not sure that something common really helps here. Drivers
using "phy" can continue to and new ones use "phy-handle". After a
quick scan, there doesn't appear to be any multi-line pattern in the
drivers we could factor out.

Rob

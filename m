From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/3] net: ethoc: document OF bindings
Date: Mon, 27 Jan 2014 13:12:33 -0800
Message-ID: <CAGVrzcb0RzOgT+bT250vFU=Bxe8_nJ56QSz9t+6yRmw+jPf-Rg@mail.gmail.com>
References: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
 <1390795167-6677-4-git-send-email-jcmvbkbc@gmail.com> <CAL_JsqLjn4FXrNGLGHs639TEqmQKPx_kk9JbAd-hn7mexzAjNg@mail.gmail.com>
 <CAMo8BfKm_rzDDs9BpfQkaew9DP9T8y0RnjzT_1gzs9Xrbx2CLA@mail.gmail.com>
 <CAGVrzcb4Y8zu6Q24-0d-uKppGE=HrvEXPUD2-Mo8r5JC80nDSw@mail.gmail.com> <CAMo8BfLhFyOY1+FJ0qh8iL969totUCmHdJ0LzyqBAzwi1-Ht=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robherring2@gmail.com>,
	"linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Chris Zankel <chris@zankel.net>,
	Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMo8BfLhFyOY1+FJ0qh8iL969totUCmHdJ0LzyqBAzwi1-Ht=A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-01-27 Max Filippov <jcmvbkbc@gmail.com>:
> On Mon, Jan 27, 2014 at 11:45 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> 2014-01-27 Max Filippov <jcmvbkbc@gmail.com>:
>>> On Mon, Jan 27, 2014 at 6:10 PM, Rob Herring <robherring2@gmail.com> wrote:
>>>> On Sun, Jan 26, 2014 at 9:59 PM, Max Filippov <jcmvbkbc@gmail.com> wrote:
>
> [...]
>
>>>>> --- /dev/null
>>>>> +++ b/Documentation/devicetree/bindings/net/opencores-ethoc.txt
>>>>> @@ -0,0 +1,25 @@
>>>>> +* OpenCores MAC 10/100 Mbps
>>>>> +
>>>>> +Required properties:
>>>>> +- compatible: Should be "opencores,ethoc".
>>>>
>>>> There are not different versions of IP or is the version probeable?
>>>
>>> AFAIK there's single version of this 10/100 MAC.
>>> It doesn't have any identification registers.
>>
>> Since this is an IP block that people can modify due to its open
>> source nature, it would have been good to define a revision register
>> or such which would allow software to gate specific code based on that
>> revision.
>
> Probably yes, though I haven't heard of any modified versions of this MAC
> out there.
>
> [...]
>
>>>>> +Examples:
>>>>> +
>>>>> +       enet0: ethoc@fd030000 {
>>>>> +               compatible = "opencores,ethoc";
>>>>> +               reg = <0xfd030000 0x4000 0xfd800000 0x4000>;
>>>>> +               interrupts = <1>;
>>>>> +               local-mac-address = [00 50 c2 13 6f 00];
>>>>> +               clock-frequency = <50000000>;
>>>>> +               mii-mgmt-clock-frequency = <5000000>;
>>
>> 5Mhz management clock? Can't you make it work with the standard 2.5Mhz
>> management clock? Is not there a risk not to be able to "talk" to some
>> PHY chips out there which do not support > 2.5Mhz management clock?
>
> Yes I can, it just didn't occur to me that there is a standard 2.5MHz setting.
>
>> Since this is an ethoc specific property, should it be prefixed with "ethoc,"?
>
> Is it worth keeping this parameter at all, or just always default to 2.5MHz?

Your example lists 5Mhz, so I assume this is of some use for you on
the platform you are working with? My concern is that this might not
be compatible with all PHY devices out there and might create hard to
debug issues where you get some MDIO transactions to succeeds and some
which don't.
-- 
Florian

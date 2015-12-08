From: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 1/2] net: cadence: macb: Disable USRIO register on
 some platforms
Date: Tue, 8 Dec 2015 10:38:36 +0100
Message-ID: <5666A51C.5060309@atmel.com>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
 <1449485914-12883-2-git-send-email-narmstrong@baylibre.com>
 <20151207193215.GI29051@jcartwri.amer.corp.natinst.com>
 <CAA3gFWtDiza1V3_eM84JxseHRDJMH_NF4Rx=-dOPD-Usp=pVNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Boris BREZILLON <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michal Simek <michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
	Josh Cartwright <joshc-acOepvfBmUk@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAA3gFWtDiza1V3_eM84JxseHRDJMH_NF4Rx=-dOPD-Usp=pVNA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 08/12/2015 10:21, Neil Armstrong a =C3=A9crit :
> Hi Josh,
>=20
> 2015-12-07 20:32 GMT+01:00 Josh Cartwright <joshc-acOepvfBmUk@public.gmane.org>:
>> On Mon, Dec 07, 2015 at 11:58:33AM +0100, Neil Armstrong wrote:
>>> On some platforms, the macb integration does not use the USRIO
>>> register to configure the (R)MII port and clocks.
>>> When the register is not implemented and the MACB error signal
>>> is connected to the bus error, reading or writing to the USRIO
>>> register can trigger some Imprecise External Aborts on ARM platform=
s.
>>> ---
>>
>> Does this make sense to even be a separate bool device tree property=
?
>>
>> This sort of configuration is typically done by:
>>    1. Creating a new 'caps' bit; relevant codepaths check that bit
>>    2. Creating a new "compatible" string for your platform's macb
>>       instance
>>    3. Creating a new 'struct macb_config' instance for your platform=
,
>>       setting any relevant caps bits when it is selected.
>>
>>   Josh
>=20
> I see the point, but according to the User Guide :
>> User I/O Register
>> The MACB design provides up to 16 inputs and 16 outputs,
>> for which the state of the I/O may
>> be read or set under the control of the processor interface.
>> If the user I/O is disabled as a configuration option, this address =
space is defined
>> as reserved, and hence will be a read-only register of value 0x0.
>=20
> On the design I worked on, the macb_user_* signals were commented,
> thus disabling this register.
>=20
> The implementation is not mandatory, and the "generic" macb compatibl=
e
> "cdns,macb" should disable
> usage of USRIO register by default and be only used for platform
> specific macb instances...
>=20
> Is it OK if I add a new 'caps' bit and use it for the "generic" macb =
instance ?

I would say no as some platform may already use this compatibility
string. So If you need a different capability set, please create a new
compatible string and use this one.

> For the device tree property, it should be safe to have the generic
> instances of macb and gem to
> rely on these properties instead of hardcoded instances.
> (it's the biggest aim of device tree, no ? no more hardcoded 'caps' b=
it ?)
> The "no-usrio" and other should eventually map 'caps' bits along the
> generic instances.

It has been decided a log time ago to use these capabilities and to hav=
e
mixed approach to the actual configuration of the IP:
- from the compatibility string
- from the configuration registers.

I may be sometimes challenging to figure out where the final property
comes from but it has proven to be pretty well adapted to any kind of
situation.

So let's continue with this and not insert additional properties to thi=
s
binding.

Best regards,
--=20
Nicolas Ferre
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

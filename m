From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: Re: Disabling autoneg and enforcing speed/duplex
Date: Thu, 06 Feb 2014 16:00:39 +0100
Message-ID: <52F3A397.3090208@keymile.com>
References: <52F3796B.8050809@keymile.com> <CAL_JsqJ=Me+MKF8DGMsh=0y4VLmekUHD7KgmQDkCpDEuKVOT+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"Brunck, Holger" <Holger.Brunck@keymile.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:32898 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbaBFPAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 10:00:43 -0500
In-Reply-To: <CAL_JsqJ=Me+MKF8DGMsh=0y4VLmekUHD7KgmQDkCpDEuKVOT+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,

thanks for your reply.

On 02/06/2014 03:50 PM, Rob Herring wrote:
> On Thu, Feb 6, 2014 at 6:00 AM, Gerlando Falauto
> <gerlando.falauto@keymile.com> wrote:
>> Hi,
>>
>> I'm using the Kirkwood Ethernet controller (mv643xx_eth.c) with a Marvell
>> 88E3018 PHY which needs to be set in forced 100Base-TX mode.
>>
>> Thanks to Sebastian's addition of DT support to the ethernet driver, I can
>> easily set speed and duplex within the ethernet's port node, therefore
>> leaving the phy unmanaged -- this works fine (I guess this mode is set on
>> the phy by the bootloader or by strap settings).
>>
>> However, this PHY has an erratum whose workaround requires some registers be
>> written -- I believe the natural solution would be to start managing the PHY
>> (i.e. set "phy-handle") and implement the proper workaround within
>> drivers/net/phy/marvell.c. Making the PHY managed does however enable
>> autoneg and therefore break everything.
>>
>> Which brings me to my question: shouldn't there be a way to specify some
>> forced settings within the PHY's node for such cases?
>>
>> Only thing I found vaguely resembling what I'm looking for is Florian's
>> patch introducing "max-speed" in the PHY -- not quite the same thing though.
>> Which, if I understand it correctly, implements it as a property of the PHY,
>> whereas ePAPR specifies it as a property of the ethernet device (which makes
>> sense, since you might want to connect a 10/100 MII to a 10/100/1000 PHY and
>> therefore have the MII restrict the capabilities of the PHY).
>
> You shouldn't need a property in this case. The driver knows what the
> h/w is limited to and can configure the phy based on that.

I see, you're right.

> It is when
> both sides should support a higher speed and you need to limit it for
> some other reason like errata or board level configuration.

Which is exactly my case. The phy should be configured to work in 
100Base-TX mode, full duplex.

>> Or perhaps I'm missing some important bits here?
>
> Does this patch help you:
>
> https://lkml.org/lkml/2014/1/15/533

I think so... So I guess I should jest set all

phy-mii-advertise-10full = <0>;
...
phy-mii-advertise-100full = <1>;
...

is that right?
I'll test it and let you know.

Thanks!
Gerlando

>
> Rob
>
>>
>> Thanks!
>> Gerlando
>> --
>> To unsubscribe from this list: send the line "unsubscribe devicetree" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

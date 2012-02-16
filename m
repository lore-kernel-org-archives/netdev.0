From: Andy Fleming <afleming@gmail.com>
Subject: Re: How to deal with a PHY configuration related to the board?
Date: Thu, 16 Feb 2012 03:51:38 -0600
Message-ID: <CAKWjMd7ZEBMC4XeqWUC=WBw9UXFDx3bt_4c3tcQOZPThRwMU+A@mail.gmail.com>
References: <20120214092606.GE4723@ldesroches-Latitude-E6320>
	<20120214094339.GA4338@sapphire.tkos.co.il>
	<20120214103318.GF4723@ldesroches-Latitude-E6320>
	<20120214112248.GA20876@game.jcrosoft.org>
	<4F3A6925.2060601@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Ludovic Desroches <ludovic.desroches@atmel.com>,
	Baruch Siach <baruch@tkos.co.il>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42406 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887Ab2BPJvj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 04:51:39 -0500
Received: by ghrr11 with SMTP id r11so1124764ghr.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 01:51:38 -0800 (PST)
In-Reply-To: <4F3A6925.2060601@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2012 at 8:01 AM, Nicolas Ferre <nicolas.ferre@atmel.com=
> wrote:
> On 02/14/2012 12:22 PM, Jean-Christophe PLAGNIOL-VILLARD :
>> On 11:33 Tue 14 Feb =A0 =A0 , Ludovic Desroches wrote:
>>> Hi Baruch,
>>>
>>> On Tue, Feb 14, 2012 at 11:43:39AM +0200, Baruch Siach wrote:
>>>> Hi Ludovic,
>>>>
>>>> On Tue, Feb 14, 2012 at 10:26:06AM +0100, Ludovic Desroches wrote:
>>>>> I am using a Micrel KSZ9021RN PHY and I would like to configure s=
ome
>>>>> registers
>>>>> as 'RGMII Clock and Control Pad Skew' and 'RGMII RX Data Pad Skew=
'.
>>>>> So the values of these registers are board dependant and I wonder=
ing what is
>>>>> the proper way to set them.
>>>>> It seems there is no platform data usable for this case. Having a=
 quick look
>>>>> to other PHYs, the situation seems the same.
>>>>>
>>>>> Can you give me some clues about how to do this? Did I miss anyth=
ing which
>>>>> allow to do this?
>>>>
>>>> See ksz9021rn_phy_fixup() in arch/arm/mach-imx/mach-imx6q.c.
>>>>
>>>
>>> Thanks for your help.
>>>
>>> So the solution is to use phy_register_fixup function.

phy_register_fixup() is the appropriate method.


>> dts
>
> ?
>
> Can you please build sentences?
>
> (even if I suspect to know what you are talking about ;-))


I'm going to take this moment to grumble about the dts solution, which
is less flexible than the fixup solution, while impeding the sharing
of knowledge and code.

'RGMII Clock and Control Pad Skew' and 'RGMII RX Data Pad Skew' sound
like features that a variety of board vendors might want to configure
differently, so why not implement code which modifies those values in
the driver, and then have the board code register a fixup which calls
that code? Then we all know what's happening, and why. The "dts"
solution is just to do a series of undocumented register writes. We
are thus left unenlightened.

Andy

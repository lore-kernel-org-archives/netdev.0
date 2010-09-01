From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: cxacru: USB ethernet port of CX82310-based ADSL routers?
Date: Wed, 01 Sep 2010 07:40:26 +0100
Message-ID: <4C7DF55A.3080007@simon.arlott.org.uk>
References: <201008312313.39171.linux@rainbow-software.org> <4C7D7F15.9040402@simon.arlott.org.uk> <201009010048.44644.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: accessrunner-general@lists.sourceforge.net, netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:49822 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab0IAGkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 02:40:32 -0400
In-Reply-To: <201009010048.44644.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/08/10 23:48, Ondrej Zary wrote:
> On Wednesday 01 September 2010 00:15:49 Simon Arlott wrote:
>> On 31/08/10 22:13, Ondrej Zary wrote:
>> > Hello,
>> > I have an ADSL router based on Conexant CX82310 chip. This chip provides
>> > both ethernet and USB interfaces. The ethernet interface is often
>> > internally connected to a 5-port switch (in my case too). The USB
>> > interface works as an ethernet card in Windows (using proprietary
>> > driver). In Linux, the cxacru driver binds to the device but does not
>> > work (no wonder - it's doing firmware things in an attempt to bring an
>> > ADSL modem up).

If you get the firmware loaded, it may implement an existing protocol
for ethernet over USB like all the ATM modems linux supports do.

>> > I wonder how to implement support for this device in cxacru driver. Or
>> > would be a separate driver better?
>>
>> Support for this shouldn't really go into the cxacru driver, as that's
>> for an USB ATM interface (it depends on usbatm for actual ATM traffic)
>> not ethernet.
> 
> That's what I was afraid of...

The firmware loading process is likely to be similar if not identical,
but these devices usually don't respond to the status command after
loading with the ADSL firmware.

>> Unfortunately it doesn't look like a trivial task to auto-detect which
>> driver should handle it... your device itself claims to be an "ADSL
>> Modem".
> 
> In fact, it does not. The idProduct text is from usb.ids file (which is often 
> incorrect). The device says that it's "USB NET CARD" (iProduct). But I don't 
> know if Linux can match drivers by iProduct string.

The probe function could ignore it allowing another driver to take it.

> 
> Maybe ignoring the device if class is 255 and iProduct is "USB NET CARD" (or 
> does not contain "MODEM"?). 
> 
> All these devices seem to use bDeviceClass 0 and iProduct "ADSL USB MODEM".
> 

However, there may be others that don't. I only have three variants of
a generic device rebranded... although they don't appear to have a way
of replacing that string. Ignoring "USB NET CARD" would be reasonable.

-- 
Simon Arlott

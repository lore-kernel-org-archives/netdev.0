From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Tue, 05 Jan 2010 08:34:45 +0100
Message-ID: <87iqbhuhre.fsf@nemi.mork.no>
References: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
	<1261604906.609.106.camel@localhost.localdomain>
	<878wcdx6tt.fsf@nemi.mork.no>
	<1262639441.16627.322.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38408 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754214Ab0AEHnV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 02:43:21 -0500
In-Reply-To: <1262639441.16627.322.camel@localhost.localdomain> (Marcel
	Holtmann's message of "Mon, 04 Jan 2010 13:10:41 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann <marcel@holtmann.org> writes:

> Hi Bjorn,
>
>> >> This patch adds the Sony Ericsson J105i (Naite)
>> >> mobile phone to the cdc_ether device whitelist,
>> >> enabling access to the modem.
>> >>=20
>> >> I would think more SE models of this generation
>> >> (2009Q3) with builtin HSDPA modules also needs
>> >> to be added to this list.
>> >
>> > I do prefer if we NOT use the mbm_info details for this since they=
 are
>> > clearly for mobile broadband cards with FLAG_WWAN.
>>=20
>> Assuming that these devices can be configured just like the WWAN car=
ds
>> by sending commands to the associated ACM* or WDM* interfaces, why w=
ould
>> you treat them differently?  Because they've got a keyboard and a
>> display?
>
> these are not like MBM devices WWAN cards. The MBM cards require to
> setup the PDP context before the card will become ready. With an actu=
al
> phone you are already set.

You are?  AFAIK, the PDP context *may* be configured using the phone UI
but it still needs to be setup.  And there are good reasons why you'd
like to configure/setup/verify the PDP context from the PC even if one
is setup using the phone UI. You will at least need to verify that a PD=
P
context actually *is* setup.  And you might want to use a different APN
than the one used when surfing from the phone.  You might even want to
choose different APNs depending on context (for VPN access, e.g)

> So these are Ethernet devices and not WWAN cards.

Well, I argued that the WWAN card were Ethernet devices.  I realise tha=
t
they've been defined otherwise now.  What I'm trying to understand are
the finer details of this definition.  Exactly what defines a WWAN card=
?

>> > Since this is a phone where the setup of the connection is done vi=
a the
>> > phone. And you just treat this as an Ethernet device and run DHCP,=
 then
>> > please create a se_info or similar with FLAG_ETHER.
>>=20
>> Why would anyone want to setup the connection via the phone?  That s=
eems
>> unnecessary cumbersome. I'd prefer such devices to be auto-configure=
d
>> just like any other WWAN device.
>
> Are they WWAN devices? What these do is basically tethering via an
> Ethernet like device. It does not require a telephony stack to drive
> this hardware.

Do they connect automatically, or do you need to initiate the connectio=
n
somehow?

> We require a proper DEVTYPE classification and these don't fall into =
the
> category of WWAN devices. They can be treated like every other Ethern=
et
> card and should be classified like this. We have FLAG_ETHER for this,=
 so
> please use that one.

I believe the WWAN cards also can be treated like every other USB
Ethernet device, as far as the kernel is concerned.  Any differences ar=
e
easily resolved by userspace applications.=20

So I'm still trying to figure out what makes a WWAN device special wrt
the kernel.  Thanks for explaining.


Bj=C3=B8rn

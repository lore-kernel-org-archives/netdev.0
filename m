From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [BUG] SIOCSIFFLAGS returns -EIO on SMSC LAN911x
Date: Mon, 2 Jan 2012 19:37:03 +0100
Message-ID: <CAAwP0s1KV0gCWXB4-sNDjyVKETGrp9xO8VmAnbJHHCupf4P5pg@mail.gmail.com>
References: <CAAwP0s37E=9J-KR397snkvq=idrc7nmELDJKrm33reeK84wJYQ@mail.gmail.com>
 <1325242573.13595.71.camel@deadeye> <CAAwP0s0Y329AAXpHW9muOECt5DpgpDm6kefXR7uE1233A1LGWg@mail.gmail.com>
 <1325250948.13595.100.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Enric Balletbo i Serra <eballetbo@iseebcn.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:39794 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791Ab2ABShY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 13:37:24 -0500
Received: by ggdk6 with SMTP id k6so9539285ggd.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 10:37:24 -0800 (PST)
In-Reply-To: <1325250948.13595.100.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 30, 2011 at 2:15 PM, Ben Hutchings <ben@decadent.org.uk> wr=
ote:
> On Fri, 2011-12-30 at 13:58 +0100, Javier Martinez Canillas wrote:
>> On Fri, Dec 30, 2011 at 11:56 AM, Ben Hutchings <ben@decadent.org.uk=
> wrote:
>> > On Fri, 2011-12-30 at 10:44 +0100, Javier Martinez Canillas wrote:
> [...]
>> >> Did anyone have the same problem?
>> >>
>> >> The problem is really strange to me, especially since we are sure=
 that
>> >> all the requirements to software reset the device are meet in bot=
h
>> >> cases (with SMSC_PHY compiled built-in and without it)
>> >
>> > I don't know about that. =C2=A0smsc_phy_config_init() attempts to =
enable
>> > power-saving on the PHY, but it is writing to a bit that is reserv=
ed
>> > according to the data sheet for the combined MAC/PHY chip. =C2=A0d=
wein
>>
>> Since the PHY chip is a lan8700, the power-saving seems to be correc=
t.
>
> But the feature may not be supported in the combined chip, the 9221i.=
 =C2=A0I
> would tend to believe the more specific data sheet.
>
>> But the problem is when latter in the open handler a software reset =
is
>> attempt.
>>
>> Probably I can protect the software reset and only try to reset the
>> device if the PHY is now in a low power mode. But if we don't reset
>> the device at interface bringing up, when should we do a the reset?
>
> You may have to change the order of initialisation of the PHY and MAC=
 so
> that reset works properly.
>
>> I'm not that familiarized with the networking layer, if someone can
>> give me some light I can fix the issue and send a patch.
>
> This really doesn't have much to do with general networking, only phy=
lib
> and the specifics of the SMSC hardware and drivers. =C2=A0The smsc911=
x driver
> is responsible for calling phylib functions and so the hardware
> initialisation is very much under its control.
>
> Ben.

Hello Ben,

Thanks for your help.

=46inally, what I did was to bring to operational mode the integrated
PHY chip by disabling the energy detect power-down mode before doing a
software reset and re-enabling after it.

Does that solution make sense to you? I've sent the patch-set to the
list for review. The patch-set is composed of the following patches:

Javier Martinez Canillas (2):
      net: phy: smsc: Move SMSC PHY constants to <linux/smscphy.h>
      net/smsc911x: Check if PHY is in operational mode before software=
 reset

Thanks a lot and best regards,

--=20
Javier Mart=C3=ADnez Canillas
(+34) 682 39 81 69
Barcelona, Spain

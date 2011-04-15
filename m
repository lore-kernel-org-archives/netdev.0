From: Andy Fleming <afleming@gmail.com>
Subject: Re: SMSC 8720a/MDIO/PHY help.
Date: Fri, 15 Apr 2011 16:02:21 -0500
Message-ID: <BANLkTi=rzTCTackMiKRW=vciN=+ThiCGJg@mail.gmail.com>
References: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E632@EXV1.corp.adtran.com>
	<1302729564.2742.28.camel@malcolm>
	<9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8D4@EXV1.corp.adtran.com>
	<BANLkTik7xeMnx0S2m0easY0hVT_UmomjzA@mail.gmail.com>
	<9AC3F0E75060224C8BBC5BA2DDC8853A1FB11170@EXV1.corp.adtran.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: michael@riesch.at, netdev@vger.kernel.org
To: ANDY KENNEDY <ANDY.KENNEDY@adtran.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:63018 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755881Ab1DOVCV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 17:02:21 -0400
Received: by pzk9 with SMTP id 9so1141402pzk.19
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 14:02:21 -0700 (PDT)
In-Reply-To: <9AC3F0E75060224C8BBC5BA2DDC8853A1FB11170@EXV1.corp.adtran.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2011 at 3:53 PM, ANDY KENNEDY <ANDY.KENNEDY@adtran.com>=
 wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Andy Fleming
>> Sent: Friday, April 15, 2011 3:30 PM
>> To: ANDY KENNEDY
>> Cc: michael@riesch.at; netdev@vger.kernel.org
>> Subject: Re: SMSC 8720a/MDIO/PHY help.
>>
>> On Wed, Apr 13, 2011 at 4:38 PM, ANDY KENNEDY
>> <ANDY.KENNEDY@adtran.com> wrote:
>> >> -----Original Message-----
>> >> From: Michael Riesch [mailto:michael@riesch.at]
>> >> Sent: Wednesday, April 13, 2011 4:19 PM
>> >> To: netdev@vger.kernel.org
>> >> Cc: ANDY KENNEDY
>> >> Subject: Re: SMSC 8720a/MDIO/PHY help.
>> >>
>> >>
>> >> > If you have an idea of something for me to try, I'd love to
>> >> entertain
>> >> > it.
>> >>
>> >> I am rather new to PHYLIB, but these are my ideas:
>> >>
>> >> =A01) make sure phy_connect is executed (AFIAK called by MDIO bus
>> >> driver)
>> >
>> > Going through the phy.txt doc under Documentation/networking:
>> > PHY Abstraction Layer
>> > (Updated 2008-04-08)
>> > though it may be a bit out-of-date, I did see what you are
>> talking about. =A0What I'm hung up on at the moment is the behavior
>> of adjust_link(). =A0It appears that I only need to start the queues=
,
>> though I don't know.
>> >
>> >>
>> >> =A02) maybe you need to call phy_start / phy_stop (AFAIK from the
>> PHY
>> >> driver's open / close function)
>> >
>> > Currently, when I do this I only get the call to adjust_link()
>> over and over again.
>>
>>
>> ...this means that the state machine is running. =A0The PHY is
>> polling
>> every couple seconds to report the current state. It calls
>> adjust_link() to keep the net_device up-to-date on that state. What
>> other behavior are you expecting to see?
>
> Well, you see I was expecting it to be up and running at that point (=
to be able to assign an IP, pass traffic, etc) -- but that is due to ig=
norance of (1) network device drivers, (2) PHY device drivers, (3) MDIO=
 bus drivers, (4) General level 2 networking, (5) ;) get the point?
>
> See, I'm totally new to networking (at this level). =A0Device drivers=
, yes, but not networking.
>
> Though, after Michael's e-mails, I have discovered that I have to
> 1) Make the MDIO bus work
> 2) Establish communications with the MDIO driver (in this case smsc.c=
 under net/phy)
> 3) Make all my NDO required functions for controlling the "real" netw=
ork device -- I was unaware that the PHY _WASN'T_ the network device.
> 4) Call phy_connect_direct (so I don't trash the already existent sms=
c.c as before stated)
> 5) Finally, after the NDO functions are written, register the NDO wit=
h the networking layer of the Kernel.
>
> One thing I have done wrong (realized AFTER depending upon the work I=
've done) is that I should have split out the MDIO and the network devi=
ce.
>
> Now, where is the document that explains all this. =A0The PHY documen=
t is very informative, however, if you don't know that a PHY is NOT a n=
etwork device, you're kinda outta luck. =A0Even Wiki reports a PHY as t=
he Physical Link layer of the OSI model. =A0Which, again, doesn't tell =
the ignorant much.


Take a look at Documentation/networking/netdevices.txt

Also grep around in drivers/net to see networking drivers that have
been ported to use phylib (look for phy_connect or phy_attach).

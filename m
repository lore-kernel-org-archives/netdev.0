From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC 43/72] a2065/ariadne: Move the a2065/ariadne drivers
Date: Mon, 11 Jul 2011 11:51:33 +0200
Message-ID: <CAMuHMdXkGfXrjD-9yYpsp0sqsdEMNxKHDNnJ8=rKJ-mtEL+QkA@mail.gmail.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1309010363-22750-44-git-send-email-jeffrey.t.kirsher@intel.com>
	<BANLkTin_SRhrd4dnfBH48b1aTikw5-mjtg@mail.gmail.com>
	<1310221836.26989.11.camel@jtkirshe-mobl>
	<CAMuHMdVHRNk4arc75QKrzDmHYE+86NixPk6v9uGwOAPkUTCgJw@mail.gmail.com>
	<1310345295.26989.76.camel@jtkirshe-mobl>
	<CAMuHMdXfpbbfv7oT+0oDWJd0=x0BBqEeCcGWaxMHagTXoeCscQ@mail.gmail.com>
	<1310377198.26989.90.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:57464 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab1GKJvd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 05:51:33 -0400
Received: by iyb12 with SMTP id 12so3508732iyb.19
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 02:51:33 -0700 (PDT)
In-Reply-To: <1310377198.26989.90.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 11:39, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> On Sun, 2011-07-10 at 23:33 -0700, Geert Uytterhoeven wrote:
>> On Mon, Jul 11, 2011 at 02:48, Jeff Kirsher <jeffrey.t.kirsher@intel=
=2Ecom> wrote:
>> > On Sun, 2011-07-10 at 12:34 -0700, Geert Uytterhoeven wrote:
>> >> On Sat, Jul 9, 2011 at 16:30, Jeff Kirsher
>> >> <jeffrey.t.kirsher@intel.com> wrote:
>> >> > On Tue, 2011-06-28 at 13:33 -0700, Geert Uytterhoeven wrote:
>> >> >> And (in some other patch) 82596.c is an Intel driver, not a
>> >> Motorola driver.
>> >> >
>> >> > 82596.c is not an Intel driver, it is an Intel part. =C2=A0The =
driver was
>> >>
>> >> Sorry, I meant "driver for an Intel part".
>> >>
>> >> > written and support by someone other than Intel. =C2=A0I am loo=
king at
>> >> how to
>> >>
>> >> Sure. But I'm strongly against classifying drivers based on who w=
rote
>> >> them ;-)
>> >
>> > I agree to some extent, because if that were the case, we would ha=
ve a
>> > donald_becker/ directory for several of the drivers. :)
>> >
>> > Here is one of the problem's I keep running into and there is no s=
imple
>> > answer. =C2=A0While most of the drivers can be grouped together by=
 the
>> > hardware they use, that does not work "logically" for every driver=
=2E
>> >
>> > In addition, if vendor 'A' makes a part and vendor 'B' uses same p=
art in
>> > a device/system/NIC and vendor 'B' creates the driver, supports th=
e
>> > driver and maintains the driver. =C2=A0Should the part be categori=
zed under
>> > vendor 'A'? =C2=A0IMHO, I think it should be categorized as a vend=
or 'B'
>> > driver.
>>
>> Several of the Ethernet drivers are of a third type: vendor A chip, =
vendor B
>> card, entity C software.
>>
>> > I started this work with the idea of trying to organize the driver=
s in
>> > the same way that the drivers were to be in the Kconfig, which ten=
ded to
>> > be drivers/net/ethernet/<manufacturer>.
>> >
>> > One of the problems that arise in this organization is what do we =
do
>> > when vendor A is bought by vendor B, and vendor B takes on the sup=
port
>> > of all the old vendor A parts/drivers?
>>
>> We don't care. We don't sort drivers by who support them. Eventually=
, vendors
>> lose interest and they all end up under "Linux kernel community" any=
way.
>
> It may just be me, these statements seem negative and bitter and is n=
ot
> helping us "solve" the issue. =C2=A0While the statements may be true,=
 =C2=A0I
> would like to try and find a solution, what ever it may be, to better
> organize drivers/net/ethernet/ drivers to help with maintenance and
> future development.
>
>> > So I am open to suggestions. =C2=A0The process I have using to org=
anize the
>> > drivers has been to group drivers that use common libraries and/or=
 code
>> > first, then group by either manufacturer, maintainer, or common
>> > platform.
>> >
>> > I would like to keep the lasi_82506.c, sni_82596.c, 82506.c and si=
milar
>> > drivers out of the intel/ directory because we would not be suppor=
ting
>> > the drivers and they are not similar to our drivers that we do sup=
port
>> > that would be in the intel/ directory.
>> >
>> > Again, I open to suggestions on how to best organize these types o=
f
>> > drivers. =C2=A0Maybe create a misc/ or <bus_type>/ for these types=
 of
>> > drivers?
>>
>> "Similar" drivers should be together and consolidated (if someone ha=
s time
>> to do it). They can even be of different brands.
>> I.e. not all Tulip-compatibles were manufactured by Digital or Intel=
=2E
>
> I agree and understand, that is why I am taking the time to do it. =C2=
=A0The
> drivers/net/ethernet/8390/, drivers/net/ethernet/tulip and
> drivers/net/ethernet/sun/ are some examples of this.

I have no problems with moving all 82596 drivers to drivers/net/etherne=
t/intel/.

>> >> > better organize the 82596.c, lasi_82596.c, lib82596.c, and
>> >> sni_82596.c
>> >> > which all use an Intel Ethernet chip but were written and suppo=
rted
>> >> by
>> >> > someone other than Intel.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds

From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 21:09:16 +0100
Message-ID: <4F0F3DEC.4050605@broadcom.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com>
 <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net>
 <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net>
 <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net>
 <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
 <CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
 <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
 <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <CA+55aFzNJbM=ohXninJ06518e3a6E8vySg8GT6dx+Qovk1QW0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Larry Finger" <Larry.Finger@lwfinger.net>,
	"Alwin Beukers" <alwin@broadcom.com>,
	"Roland Vossen" <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1641 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755224Ab2ALUJe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 15:09:34 -0500
In-Reply-To: <CA+55aFzNJbM=ohXninJ06518e3a6E8vySg8GT6dx+Qovk1QW0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2012 08:08 PM, Linus Torvalds wrote:
> On Thu, Jan 12, 2012 at 11:00 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> I'll send out a patch that seems to get things to a working state fo=
r
>> me. At least I have wireless connectivity again, I don't know if the=
re
>> are some other problems remaining.
>=20
> Ok, this is the patch that gets me going, and this is sent from the M=
acbook Air.
>=20
> NOTE! The BCMA confusion about the sprom still exists, but doesn't
> seem to matter:

That is because brcmsmac is not relying on the sprom logic provided by
bcma. As Rafa=B3 indicated that is duplicated code so if we are to use
bcma sprom functionality that needs to be fixed (after the merge window=
).

>  bcma: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x22, cla=
ss 0x0)
>  bcma: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x17, cl=
ass 0x0)
>  bcma: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x0F, class 0x0=
)
>  bcma: Found rev 6 PMU (capabilities 0x108C2606)
>  bcma: Unsupported SPROM revision: 255
>  bcma: No SPROM available
>  bcma: Bus registered
>   ..
>  brcmsmac bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 17
>  brcmsmac: Found chip type AI (0x1381a8d8)
>  brcmsmac: Applying 43224B0+ WARs
>  bcma: Switched to core: 0x812
>  ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
>  brcms_module_init: register returned 0
>=20
> so this does seem to work, but there are clearly some issues still..
>=20
>                  Linus

That output look fine. The patch looks fine although you can use the ne=
w
do_crc_check() function in otp_read_pci as well.

Gr. AvS

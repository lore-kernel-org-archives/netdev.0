From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 3/3] qmi_wwan: Driver for WWAN devices requiring use of the QMI protocol
Date: Thu, 15 Dec 2011 11:02:22 +0100
Message-ID: <87r506b1ap.fsf@nemi.mork.no>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
	<1323750784-32608-4-git-send-email-bjorn@mork.no>
	<1323882501.2077.3.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323882501.2077.3.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org> (Dan Williams's message
	of "Wed, 14 Dec 2011 11:08:21 -0600")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> So I thought the protocol acronym stood for "Qualcomm MSM/Modem
> Interface"  (see
> https://www.codeaurora.org/gitweb/quic/le/?p=3Dkernel/msm.git;a=3Dcom=
mitdiff;h=3D5f6f87b51184e13b6c493012de787895d5d18765)

That's probably correct.  Don't know where I got the messaging part
from.  Should be corrected....

> In any case, great work here.  But I'm a bit concerned about how all
> this should fit together.  QMI is a huge protocol that does everythin=
g a
> modem would ever want to do, and we'd likely want to be able to speak
> QMI from userspace to the modem too so that modem managers can expose
> the full functionality of the modems.  For example Gobi modems have a
> very minimal AT command set and most of the functionality is exposed
> over QMI or DM.  That's why the Qualcomm GobiNet driver also
> exposed /dev/qmi for userspace access.

Yes, I believe some interface should be exported.  But my primary goal
was to make something that would just work as an ethernet device with a
minimum of external userspace dependencies.  And this modem seems to
have a fairly complete set of AT commands anyway.  Ideally I would want
to stick

 auto wwan0
 iface wwan0 inet dhcp

in my /etc/network/interface and not need any application for that to
work.  But I realize that I must enter a SIM PIN1 code first (unless
disabled), and that most users will want to configure a specific APN
(although the null APN "" most likely will work just fine).

But I agree that eventually the full QMI protocol should be made
available to userspace for other uses.  That should be fairly easy to d=
o
if you just proxy the commands.  But I'm worring about the interface.
Is the /dev/qmi from GobiNet acceptable?  Why isn't it merged yet?
Wouldn't something like netlink have been more suitable?  How about
security and the ability to control privileges on a command to command
basis?  And are there users?  Note that even the Windows application
supplied with the modem uses AT commands for SMS sending/receiving etc.
The snoop I did showed a very minimal set of QMI commands.  These were
all Windows used for startup of the network interface (partly decoded b=
y
me):


=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x01
=2Emsgid =3D 0x0021
=2Elen =3D 0x0004
[0x01] (1)  ff	.

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x02
=2Emsgid =3D 0x0021
=2Elen =3D 0x0004
[0x01] (1)  ff	.

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x03
=2Emsgid =3D 0x0021
=2Elen =3D 0x0004
[0x01] (1)  ff	.

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x04
=2Emsgid =3D 0x0021
=2Elen =3D 0x0004
[0x01] (1)  ff	.

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x05
=2Emsgid =3D 0x0021
=2Elen =3D 0x0004
[0x01] (1)  ff	.

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x06
=2Emsgid =3D 0x0021
=2Elen =3D 0x0004
[0x01] (1)  ff	.

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x07
=2Emsgid =3D 0x0021
=2Elen =3D 0x0004
[0x01] (1)  ff	.

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x08
=2Emsgid =3D 0x0021
=2Elen =3D 0x0004
[0x01] (1)  ff	.

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x09
=2Emsgid =3D 0x0021
=2Elen =3D 0x0004
[0x01] (1)  ff	.

=2Etf =3D 0x01
=2Elen =3D 0x000b
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x02 response
=2Etid =3D 0x00
=2Emsgid =3D 0x0027
=2Elen =3D 000000

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x0a
=2Emsgid =3D 0x0021
=2Elen =3D 0x0004
[0x01] (1)  ff	.

=2Etf =3D 0x01
=2Elen =3D 0x0057
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x01 invalid
=2Etid =3D 0x0a
=2Emsgid =3D 0x0021
=2Elen =3D 0x004c
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (66)  0d 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00 d1 0e 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00	..=
=2E...............................................................

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x0b
=2Emsgid =3D 0x0022
=2Elen =3D 0x0004
[0x01] (1)  02	.

=2Etf =3D 0x01
=2Elen =3D 0x0017
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x01 invalid
=2Etid =3D 0x0b
=2Emsgid =3D 0x0022
=2Elen =3D 0x000c
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (2)  02 01	..

=2Etf =3D 0x01
=2Elen =3D 0x000c
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x02
=2Eqmicid =3D 0x01
=2Eflags =3D 0x00 request
=2Etid =3D 0x0001
=2Emsgid =3D 0x0021
=2Elen =3D 000000

=2Etf =3D 0x01
=2Elen =3D 0x002b
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x02
=2Eqmicid =3D 0x01
=2Eflags =3D 0x02 response
=2Etid =3D 0x0001
=2Emsgid =3D 0x0021
=2Elen =3D 0x001f
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (21)  51 55 41 4c 43 4f 4d 4d 20 49 4e 43 4f 52 50 4f 52 41 54 4=
5 44	QUALCOMM INCORPORATED

=2Etf =3D 0x01
=2Elen =3D 0x000c
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x02
=2Eqmicid =3D 0x01
=2Eflags =3D 0x00 request
=2Etid =3D 0x0002
=2Emsgid =3D 0x0024
=2Elen =3D 000000

=2Etf =3D 0x01
=2Elen =3D 0x0013
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x02
=2Eqmicid =3D 0x01
=2Eflags =3D 0x02 response
=2Etid =3D 0x0002
=2Emsgid =3D 0x0024
=2Elen =3D 0x0007
[0x02] (4) FAILED (0x0025) QMI_ERR_UIM_NOT_INITIALIZED

=2Etf =3D 0x01
=2Elen =3D 0x000c
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x02
=2Eqmicid =3D 0x01
=2Eflags =3D 0x00 request
=2Etid =3D 0x0003
=2Emsgid =3D 0x0025
=2Elen =3D 000000

=2Etf =3D 0x01
=2Elen =3D 0x0029
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x02
=2Eqmicid =3D 0x01
=2Eflags =3D 0x02 response
=2Etid =3D 0x0003
=2Emsgid =3D 0x0025
=2Elen =3D 0x001d
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x10] (1)  30	0
[0x11] (15)  38 36 30 39 39 39 30 30 30 30 32 33 37 30 37	8609990000237=
07

=2Etf =3D 0x01
=2Elen =3D 0x0010
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x0c
=2Emsgid =3D 0x0023
=2Elen =3D 0x0005
[0x01] (2)  02 01	..

=2Etf =3D 0x01
=2Elen =3D 0x0017
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x01 invalid
=2Etid =3D 0x0c
=2Emsgid =3D 0x0023
=2Elen =3D 0x000c
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (2)  02 01	..

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x0d
=2Emsgid =3D 0x0022
=2Elen =3D 0x0004
[0x01] (1)  01	.

=2Etf =3D 0x01
=2Elen =3D 0x0017
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x01 invalid
=2Etid =3D 0x0d
=2Emsgid =3D 0x0022
=2Elen =3D 0x000c
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (2)  01 01	..

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x0e
=2Emsgid =3D 0x0020
=2Elen =3D 0x0004
[0x01] (1)  00	.

=2Etf =3D 0x01
=2Elen =3D 0x0017
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x01 invalid
=2Etid =3D 0x0e
=2Emsgid =3D 0x0020
=2Elen =3D 0x000c
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (2)  00 00	..

=2Etf =3D 0x01
=2Elen =3D 0x000b
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x02 response
=2Etid =3D 0x00
=2Emsgid =3D 0x0027
=2Elen =3D 000000

=2Etf =3D 0x01
=2Elen =3D 0x000b
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x02 response
=2Etid =3D 0x00
=2Emsgid =3D 0x0027
=2Elen =3D 000000

=2Etf =3D 0x01
=2Elen =3D 0x000b
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x02 response
=2Etid =3D 0x00
=2Emsgid =3D 0x0027
=2Elen =3D 000000

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x0f
=2Emsgid =3D 0x0022
=2Elen =3D 0x0004
[0x01] (1)  02	.

=2Etf =3D 0x01
=2Elen =3D 0x0017
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x01 invalid
=2Etid =3D 0x0f
=2Emsgid =3D 0x0022
=2Elen =3D 0x000c
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (2)  02 02	..

=2Etf =3D 0x01
=2Elen =3D 0x000c
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x02
=2Eqmicid =3D 0x02
=2Eflags =3D 0x00 request
=2Etid =3D 0x0001
=2Emsgid =3D 0x0022
=2Elen =3D 000000

=2Etf =3D 0x01
=2Elen =3D 0x0017
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x02
=2Eqmicid =3D 0x02
=2Eflags =3D 0x02 response
=2Etid =3D 0x0001
=2Emsgid =3D 0x0022
=2Elen =3D 0x000b
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (1)  30	0

=2Etf =3D 0x01
=2Elen =3D 0x000f
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x00 request
=2Etid =3D 0x10
=2Emsgid =3D 0x0022
=2Elen =3D 0x0004
[0x01] (1)  01	.

=2Etf =3D 0x01
=2Elen =3D 0x0017
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x00
=2Eqmicid =3D 0x00
=2Eflags =3D 0x01 invalid
=2Etid =3D 0x10
=2Emsgid =3D 0x0022
=2Elen =3D 0x000c
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (2)  01 02	..

=2Etf =3D 0x01
=2Elen =3D 0x000c
=2Ectrl =3D 0x00 control point
=2Eservice =3D 0x01
=2Eqmicid =3D 0x02
=2Eflags =3D 0x00 request
=2Etid =3D 0x0002
=2Emsgid =3D 0x0022
=2Elen =3D 000000

=2Etf =3D 0x01
=2Elen =3D 0x0017
=2Ectrl =3D 0x80 service
=2Eservice =3D 0x01
=2Eqmicid =3D 0x02
=2Eflags =3D 0x02 response
=2Etid =3D 0x0002
=2Emsgid =3D 0x0022
=2Elen =3D 0x000b
[0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
[0x01] (1)  01	.



> Second, does the modem actually respond to DHCP over the ECM interfac=
e?

Yes.  And IMHO that's the only sensible thing to do.  Cannot be very
difficult to implement that feature in the firmware.  It's not like you
need to write a dhcp server.  You know you have only a single client on
the other end of a point-to-point link, and the address configuration i=
s
given.  And all broadcast/multicast requires special treatment anyway.
I actually thought about implementing the DHCP functionality in the
driver before I knew that the firmware already provided this.

=46WIW, the Windows driver implementation also depends on DHCP for addr=
ess
configuration .

> If you take a look at the Android rmnet code (which is similar to you=
r
> driver) you'll see they extract the IP address and DNS details from t=
he
> QMI response.  Do we need to do that here too?

Based on the above, I don't think so. =20

And if you still want to extract address details without using DHCP,
then that information is available via the AT^DHCP? command anyway.  Yo=
u
don't need QMI for that part.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

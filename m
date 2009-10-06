From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [7/8,RFC] CAIF Protocol Stack
Date: Tue, 6 Oct 2009 21:41:28 +0200
Message-ID: <61D8D34BB13CFE408D154529C120E07902ED671E@eseldmw101.eemea.ericsson.se>
References: <1253727096-10413-1-git-send-email-sjur.brandeland@stericsson.com> <4ACA1D31.6000008@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>
To: "Stefano Babic" <stefano.babic@babic.homelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:59809 "EHLO
	mailgw4.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932330AbZJFTmV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 15:42:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4ACA1D31.6000008@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefano Babic wrote:
> It seems that this command requires additional parameters as PRIO and
> PHYPREF, else a "parse error" is reported by the tool.=20

Yes, I'll fix this documentation in a new PATCH delivery (hopefully) th=
is week.

=20
>>"CAIF Protocol Specification" (155 19-CRH 109 913).=20
> Is this one an internal document or was it published and is available
> for reading ?=20

No, not yet unfortunately.


> Is phyif_msl.ko obsolete ? There is no track of the corresponding
> source file.=20

Yes, it is an obsolete physical interface no longer supported.
I have removed reference to it from documentation.

> $ modprobe caif
> $ modprobe phyif_ser
> $ echo 6 > /sys/class/caif/dbg_lvl
> $ ./ldiscd
> $./chardevconfig /dev/caifconfig - CREATE TYPE=3DAT NAME=3Dchnlat10 D=
EVTYPE=3DCHAR PHYPREF=3DLAT PRIO=3DHI  =20

This looks ok.

> and the system hangs. I could find after some instrumentation that
> the system hangs in the ser_phy_tx function. This is not a surprise,
> because the Uart TX function is never called. Have I missed something
> ?  =20

Hmm, the hanging might be due to a tight loop in the phyif_ser.c:ser_ph=
y_tx function.
[snip]
		do {
			tty_wr =3D
			    pser_tty->ops->write(pser_tty, bufp, actual_len);
			/* When not whole buffer is written,
			 * forward buffer pointer and try again */
			actual_len -=3D tty_wr;
			bufp +=3D tty_wr;
		} while (actual_len);

If pser_tty->ops->write() returns zero it will loop infinetly.
I guess the proper solution would be not to loop, but to implement a wr=
ite_wakeup function for the tty...?


BR/Sjur Br=E6ndeland




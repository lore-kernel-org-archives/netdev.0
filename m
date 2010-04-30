From: d binderman <dcb314@hotmail.com>
Subject: possible off by one error in drivers/isdn/hysdn/hysdn_proclog.c
Date: Fri, 30 Apr 2010 21:23:15 +0000
Message-ID: <BLU108-W2512CBD9073AB7248051419C000@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blu0-omc3-s38.blu0.hotmail.com ([65.55.116.113]:6737 "EHLO
	blu0-omc3-s38.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752752Ab0D3V31 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 17:29:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hello there,

I've just been looking at the Linux kernel linux-2.6.34-rc6.=A0 I notic=
e the
source code in file drivers/isdn/hysdn/hysdn_proclog.c, around line 115=
 is

=A0=A0=A0=A0=A0=A0=A0 if (!(ib =3D kmalloc(sizeof(struct log_data) + st=
rlen(cp), GFP_ATOMIC)))
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 return;=A0=A0=A0=A0=A0=
=A0=A0 /* no memory */
=A0=A0=A0=A0=A0=A0=A0 strcpy(ib->log_start, cp);=A0=A0=A0=A0=A0 /* set =
output string */


Shouldn't that be

=A0=A0=A0=A0=A0=A0=A0 if (!(ib =3D kmalloc(sizeof(struct log_data) + st=
rlen(cp) + 1, GFP_ATOMIC)))
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 return;=A0=A0=A0=A0=A0=
=A0=A0 /* no memory */
=A0=A0=A0=A0=A0=A0=A0 strcpy(ib->log_start, cp);=A0=A0=A0=A0=A0 /* set =
output string */

+1 for the zero byte ?

Regards

David Binderman

 		 	   		 =20
_________________________________________________________________
http://clk.atdmt.com/UKM/go/195013117/direct/01/
We want to hear all your funny, exciting and crazy Hotmail stories. Tel=
l us now
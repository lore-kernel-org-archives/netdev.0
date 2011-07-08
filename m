From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: orphan sockets
Date: Fri, 8 Jul 2011 19:28:27 +0300
Message-ID: <CAEnQRZDWZzCCeL3auoLJ=sK5V9yi_Zxs+HgtPoeLFRUV8b0m-Q@mail.gmail.com>
References: <6fa7e62e85e1e2fd069aa9cbf307737a@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:40664 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104Ab1GHQ22 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 12:28:28 -0400
Received: by qyk29 with SMTP id 29so373566qyk.19
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 09:28:28 -0700 (PDT)
In-Reply-To: <6fa7e62e85e1e2fd069aa9cbf307737a@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2011 at 6:13 PM, Denys Fedoryshchenko <denys@visp.net.lb=
> wrote:
> Hi
>
> Just after digging orphan sockets problem, that was causing "Address =
already
> in use" for bind(),i found that in documentation is mentioned:
>
> tcp_orphan_retries - INTEGER
> =A0 =A0 =A0 =A0This value influences the timeout of a locally closed =
TCP connection,
> =A0 =A0 =A0 =A0when RTO retransmissions remain unacknowledged.
> =A0 =A0 =A0 =A0See tcp_retries2 for more details.
>
> =A0 =A0 =A0 =A0The default value is 7.
> =A0 =A0 =A0 =A0If your machine is a loaded WEB server,
> =A0 =A0 =A0 =A0you should think about lowering this value, such socke=
ts
> =A0 =A0 =A0 =A0may consume significant resources. Cf. tcp_max_orphans=
=2E

This should be 8. tcp(7) got it wright.

> But all servers i have, i notice that =A0tcp_orphan_retries =3D 0 by =
default, i
> check in code, and found that:
> =A0 =A0 =A0 =A0if (retries =3D=3D 0 && alive)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retries =3D 8;
> is a bit confusing, that tcp_orphan_retries =3D 0, is in fact =3D 8, =
or to be
> more exact is 8 if socket has rto < RTO_MAX. But nothing like 7 menti=
oned in
> documentation, i guess it is wrong?. My english too bad to edit that,=
 but
> maybe someone will take a look :-)

I guess 0 means, let the operating system to choose the default value f=
or this.
Basically, what we should do here is replace 7 with 8 in
Documentation/networking/ip-sysctl.txt
I can try to make a patch for this if you want.

thanks,
Daniel.

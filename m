From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: qmi-wwan bug
Date: Wed, 24 Oct 2012 23:19:07 +0200
Message-ID: <943c3dc1-8bc7-4678-a6fd-adc5051f331c@email.android.com>
References: <5088385C.1090304@accelecon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Shawn J. Goff" <shawn.goff@accelecon.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34591 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161209Ab2JXVTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 17:19:13 -0400
In-Reply-To: <5088385C.1090304@accelecon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



"Shawn J. Goff" <shawn.goff@accelecon.com> wrote:

>I've backported qmi-wwan to 2.6.39 (it's here:=20
>https://bitbucket.org/accelecon/linux-at91/changesets), and it mostly=20
>works, but I've come across a problem. The modem will sometimes stop=20
>responding to any qmi data (but the AT commands on the TTY ports keep=20
>working). This only happens when there is significant traffic flowing=20
>through the device (downloading a large file) while at the same time,
>AT=20
>commands are sent to one of the TTY ports (I first noticed with my own=
=20
>modem query program, but I can reproduce it using microcom to send=20
>"ATI\r" in a loop).=20

Using the tty ports should be completely independent of any qmi activit=
y from the host perspective. I am tempted to claim this indicates a fir=
mware bug.

> I see this problem with different devices from=20
>different manufacturers.=20

Which still may use pretty much the same firmware, although a little le=
ss likely.

> I've only made it happen on my kernel - I
>tried=20
>on 3.6.2, but it seems to not happen there.

Good. But I have a feeling that you switched more than just the kernel.=
 Do you see the issue if you run your backport on the same hardware you=
 tested 3.6.2 on?

 > I've also tried using a=20
>similar modem that uses a different driver (sierra-net) and that
>doesn't=20
>have the same problem.

Well, that is an entirely different firmware application and driver, ev=
en if the hardware is similar or even identical.

>When it is in failure, if I try to ping an address, the system sends
>out=20
>several an ARP requests but gets no response. To get the device to=20
>respond again, I have to administratively set the wwan interface down,=
=20
>then up, use libqmi to get the connection going again, then dhcp to ge=
t
>
>an address.

Which sounds like the connection died. Does QMI work at this point, or =
is that dead too?

>I also have some USB traces of the failure and recovery process. I'm
>not=20
>familiar with CDC or QMI, so it's not yet clear to me exactly what's=20
>happening, but it looks like the modem just stops sending anything on=20
>its QMI endpoint for no reason.
>
>How might I dive further into the issue? So far, my next step is to
>look=20
>into CDC and QMI and try to decypher the USB traces. If anyone is=20
>interested, I can share a tcpdump or a USB trace.

I think a test of the backport on the same host hardware you run 3.6.2 =
on would be the best place to start.

Bj=C3=B8rn

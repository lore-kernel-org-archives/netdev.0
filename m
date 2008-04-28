From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: WARNING: at net/ipv4/tcp_input.c
Date: Mon, 28 Apr 2008 20:07:28 +0100
Message-ID: <48162070.4030405@andyfurniss.entadsl.com>
References: <4815BCDF.6070704@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:33243 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933624AbYD1TH1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:07:27 -0400
In-Reply-To: <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Mon, 28 Apr 2008, Andy Furniss wrote:
>=20
>> Since upgrading to 2.6.25 from 2.6.21.1 I've noticed a few of these.
>=20
> ...Thanks for the report, you could actually reproduce it in non-infi=
nite=20
> time?? ...Finally somebody who might actually have a change to catch=20
> this shows up... :-)

Hopefully - grepping shows I've had a few, I was running -rc7 for a=20
while and see a different message from that. I changed to .25 on the 21=
st.

andy@noki:~$ grep WARNING /var/log/kern.log
Mar 29 20:35:03 noki kernel: WARNING: at net/ipv4/tcp_input.c:2510=20
tcp_fastretrans_alert+0x685/0x6b0()
Mar 30 03:02:04 noki kernel: WARNING: at net/ipv4/tcp_input.c:2510=20
tcp_fastretrans_alert+0x685/0x6b0()
Apr 15 05:11:02 noki kernel: WARNING: at net/ipv4/tcp_input.c:2510=20
tcp_fastretrans_alert+0x685/0x6b0()
Apr 19 17:11:36 noki kernel: WARNING: at net/ipv4/tcp_input.c:2510=20
tcp_fastretrans_alert+0x685/0x6b0()
Apr 26 19:42:33 noki kernel: WARNING: at net/ipv4/tcp_input.c:2539=20
tcp_ack+0x1dc2/0x1df0()
Apr 28 08:35:58 noki kernel: WARNING: at net/ipv4/tcp_input.c:2539=20
tcp_ack+0x1dc2/0x1df0()
Apr 28 17:38:00 noki kernel: WARNING: at net/ipv4/tcp_input.c:2539=20
tcp_ack+0x1dc2/0x1df0()

> I've tried to catch these with torrent but never got anything, it see=
ms to=20
> be quite sensitive to "network weather", which varies too much for me=
 to=20
> catch it. Maybe I'll try w/o timestamps if that helps me to reproduce=
 it=20
> (more likely).

Could be my qos shaking things up. bt uses piggy backed acks and I must=
=20
drop a fair few. I probably reorder a bit as well by treating small tcp=
=20
as higher prio than large. Egress tcp is also mss clamped to 1150.

> The debug patch below will add considerable amount of processing per =
ACK=20
> to verify where this invariant gets broken for the first time, in cas=
e=20
> that's fine with your server, please consider adding that and waiting=
=20
> until it spits something out... :-)

No problem it's 90% idle most of the time and my wan isn't that fast.

I'll rebuild tonight.

Andy.



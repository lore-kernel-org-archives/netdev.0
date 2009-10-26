From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: VLAN and ARP failure on tg3 drivers
Date: Mon, 26 Oct 2009 09:20:48 +0100
Message-ID: <m34opmr2fz.fsf@ursa.amorsen.dk>
References: <477963.52849.qm@web32605.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Gertjan Hofman <gertjan_hofman@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:59651 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755232AbZJZIUu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 04:20:50 -0400
In-Reply-To: <477963.52849.qm@web32605.mail.mud.yahoo.com> (Gertjan Hofman's
	message of "Sun, 25 Oct 2009 21:30:09 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gertjan Hofman <gertjan_hofman@yahoo.com> writes:

> Dear Matt, Eric, Benny,
>
> Sorry about the slow response to your fast replies. I think Benny is
> correct, the 'problem' lies in the fact that we were using a VLAN ID
> of 0, without knowing its special significance. User error.
>
> I tested it with other VLAN id's (>0) and it appears to work fine. We
> are not entirely sure we understand=C2=A0 why it used to work with VL=
AN ID
> 0 on the Broadcom chips and still does with a number of different
> cards (with >2.6.27 kernels).=C2=A0 What is the 'correct' behaviour f=
or
> this incorrect usage ?

VLAN 0 isn't incorrect, it's just surprising. When you send a packet
tagged with VLAN 0, it means that the packet should be interpreted as
being the same VLAN as a completely untagged packet.

So in theory, if both ends are using VLAN 0 and you aren't using eth0
for anything, traffic should flow, at least if both ends are on the sam=
e
kernel version. Feel free to debug why that isn't the case for you, of
course...


/Benny


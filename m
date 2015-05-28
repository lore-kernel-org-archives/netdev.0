From: Ken Moffat <zarniwhoop@ntlworld.com>
Subject: Re: Lost network connectivity in 4.0.x
Date: Thu, 28 May 2015 17:11:19 +0100
Message-ID: <20150528161119.GA31622@milliways>
References: <20150524024352.GA15747@milliways>
 <20150524032938.GA16664@milliways>
 <CAM_iQpXH_-WO8W=zVUaXezeGGOjFy-nBLy0k+tytZuMQqV1hcQ@mail.gmail.com>
 <20150528144149.GA29350@milliways>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from know-smtprelay-omc-7.server.virginmedia.net ([80.0.253.71]:60652
	"EHLO know-smtprelay-omc-7.server.virginmedia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754010AbbE1QLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 12:11:21 -0400
Content-Disposition: inline
In-Reply-To: <20150528144149.GA29350@milliways>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 03:41:49PM +0100, Ken Moffat wrote:
> On Wed, May 27, 2015 at 10:53:00PM -0700, Cong Wang wrote:
> > (Please always Cc netdev for networking bugs.)
> >=20
Sorry, didn't spot that.  But anyway
>=20
> > For example:
> >=20
> > 1) What is your network setup? iptables? routes? etc.
> >=20
> I'm using iptables.  Ah, yes - it started dropping packets around
> the time I last had a problem:
>=20
> May 27 00:48:26 ac4tv dhclient: DHCPREQUEST on eth0 to 192.168.7.254
> port 67
> May 27 00:48:27 ac4tv dhclient: DHCPACK from 192.168.7.254
> May 27 00:48:27 ac4tv dhclient: bound to 192.168.7.152 -- renewal in
> 1787 seconds.
>=20
>  That address came from my router, and I had been getting the same
> address for an hour, tbut then the dropped packet messages start
> appearing - they are for a different address, one that would have
> been offered by my server:
>=20
Now that I've had time to think about this and look a bit more
deeply, I can see that at one point I got a lease from my server,
but then after a random length of time the client tried to renew and
got a lease from the router.  Some time after that, it failed
because iptables rejected the nfs packets because they were "not for
me".

So, not a kernel problem, and the reason I'm (now) seeing this on
4.0+ kernels is that I have not recently booted a system with an old
(3.19 or earlier) kernel and kept it running for a long time.

Thanks again, sorry to waste everybody's bandwidth.

=C4=B8en
--=20
Nanny Ogg usually went to bed early. After all, she was an old lady.
Sometimes she went to bed as early as 6 a.m.

From: Flavio Leitner <fbl@redhat.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Wed, 16 Nov 2011 22:33:30 -0200
Message-ID: <20111116223330.08de9e52@asterix.rh>
References: <4EC2CA52.6020104@icdsoft.com>
	<1321391355.2602.0.camel@edumazet-laptop>
	<4EC439F2.3080809@icdsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ivan Zahariev <famzah@icdsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754073Ab1KQAdf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 19:33:35 -0500
In-Reply-To: <4EC439F2.3080809@icdsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2011 00:32:18 +0200
Ivan Zahariev <famzah@icdsoft.com> wrote:

> On 11/15/2011 11:09 PM, Eric Dumazet wrote:
> > Le mardi 15 novembre 2011 =C3=A0 22:23 +0200, Ivan Zahariev a =C3=A9=
crit :
> >> Hello,
> >>
> >> We have changed nothing in our network infrastructure but only
> >> upgraded from Linux kernel 2.6.36.2 to 3.0.3. Here is the problem
> >> we are experiencing:
> >>
> >> ICMP redirected routes are cached forever, and they can be cleared
> >> only by a reboot.
> >>=20
> ### (bug #1) even though we flushed the route cache, the <redirected>=
=20
> route resurrects from somewhere; even without making any TCP requests
> ### this time what "ip" returns is consistent with the real
> (incorrect) routing behavior of machine5
> root@machine5:~# ip route flush cache
> root@machine5:~# ip route list cache match 8.8.4.4
> root@machine5:~# ip route get 8.8.4.4
> 8.8.4.4 via 192.168.0.120 dev eth0  src 192.168.0.244
>      cache <redirected>  ipid 0x303a
>=20
> ### only a reboot clears the cached <redirected> routes

IIRC, the cache flush doesn't affect the inetpeer where the
redirected gateway is now stored, so even after flushing the
route cache, the inetpeer will restore the old info later.

fbl

From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Tue, 26 Mar 2013 05:40:45 -0700
Message-ID: <87wqsu72r6.fsf@xmission.com>
References: <CD773D0D.7614%blourdel@juniper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Serge Hallyn <serge.hallyn@ubuntu.com>
To: Benoit Lourdelet <blourdel@juniper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55246 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758077Ab3CZMk4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 08:40:56 -0400
In-Reply-To: <CD773D0D.7614%blourdel@juniper.net> (Benoit Lourdelet's message
	of "Tue, 26 Mar 2013 11:51:07 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benoit Lourdelet <blourdel@juniper.net> writes:

> Hello,
>
> I re-tested with the patch and got the following results on a 32x 2Gh=
z
> core system.
>
> # veth 	add 	delete
> 1000 	36 	34
> 3000 	259 	137
> 4000 	462 	195
> 5000 	729     N/A
>
> The script to create is the following :
> for i in `seq 1 5000`; do
> 	sudo ip link add type veth
> Done

Which performs horribly as I mentioned earlier because you are asking
the kernel to create the names.  If you want performance you need to
specify the names of the network devices you are creating.

aka ip link add a$i type veth name b$i

> The script to delete:
> for d in /sys/class/net/veth*; do
> 	ip link del `basename $d` 2>/dev/null || true
> Done
>
> There is a very good improvement in deletion.
>
>
>
> iproute2 does not seems to be well multithread as I get time divided =
by a
> factor of 2 with a 8x  3.2 Ghz core system.

All netlink traffic and all network stack configuration is serialized b=
y
the rtnl_lock in the kernel.  This is the slow path in the kernel, not
the fast path.

> I don=C2=B9t know if that is the improvement you expected ?
>
> Would the iproute2 redesign you mentioned help improve performance ev=
en
> further ?

Specifing the names would dramatically improve your creation
performance.  It should only take you about 10s for 5000 veth pairs.
But you have to specify the names.

Anyway I have exhausted my time, and inclination in this matter.  Good
luck with whatever your problem is.

Eric

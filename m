From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Tue, 10 Mar 2009 06:28:36 +0100
Message-ID: <49B5FA84.9000301@cosmosbay.com>
References: <20090204012144.GC3650@localhost.localdomain>	<49A6CE39.5050200@athenacr.com>	<49A8FAFF.7060104@cosmosbay.com> <20090304.001646.100690134.davem@davemloft.net> <49AE3DA9.2020103@cosmosbay.com> <49B2266C.9050701@cosmosbay.com> <49B3F655.6030308@cosmosbay.com> <49B59EA3.3000208@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kchang@athenacr.com, netdev@vger.kernel.org
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44950 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722AbZCJF2l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 01:28:41 -0400
In-Reply-To: <49B59EA3.3000208@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Bloniarz a =E9crit :
> Eric Dumazet wrote:
>> Here is a patch that helps. It's still an RFC of course, since its
>> somewhat ugly :)
>=20
> Hi Eric,
>=20
> I did some experimenting with this patch today -- we're users, not
> kernel hackers,
> but the performance looks great. We see no loss with mcasttest, and n=
o
> loss with
> our internal test programs (which do much more user-space work). We'r=
e very
> encouraged :)
>=20
> One thing I'm curious about: previously, setting
> /proc/irq/<eth0>/smp_affinity
> to one CPU made things perform better, but with this patch, performan=
ce
> is better
> with smp_affinity =3D=3D ff than with smp_affinity =3D=3D 1. Do you k=
now why that
> is? Our tests are all with bnx2 msi_disable=3D1. I can investigate wi=
th
> oprofile
> tomorrow.
>=20

Well, smp_affinity could help in my opininon if you dedicate
one cpu for the NIC, and others for user apps, if the average
work done per packet is large. If load is light, its better
to use the same cpu to perform all the work, since no expensive
bus trafic is needed between cpu to exchange memory lines.

If you only change /proc/irq/<eth0>/smp_affinity, and let scheduler
chose any cpu for your user-space work that can have long latencies,
I would not expect better performances.

Try to cpu affine your taks to 0xFE to get better determinism.




From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when	gc_elasticity
 is exceeded
Date: Mon, 20 Oct 2008 10:12:51 +0200
Message-ID: <48FC3D83.8060905@cosmosbay.com>
References: <20081016163644.GA2933@localhost.localdomain> <20081016233517.GA21243@localhost.localdomain> <20081016220624.512a1e61@extreme> <20081017103948.GA23591@hmsreliant.think-freely.org> <48F8806A.6090306@cosmosbay.com> <20081017152328.GB23591@hmsreliant.think-freely.org> <48F8AFBE.5080503@cosmosbay.com> <20081017204415.GC23591@hmsreliant.think-freely.org> <20081018005408.GB27254@localhost.localdomain> <48F967BA.4090102@cosmosbay.com> <20081020000756.GB21172@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru, Stephen Hemminger <shemminger@vyatta.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2a.orange.fr ([80.12.242.140]:40569 "EHLO smtp2a.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbYJTINb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 04:13:31 -0400
In-Reply-To: <20081020000756.GB21172@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> Ok, one more revision. It takes Erics final suggestions into account.=
  Eric, as
> per your request, I've added your signed off line to it.
>=20
>=20
> This is a patch to provide on demand route cache rebuilding.  Current=
ly, our
> route cache is rebulid periodically regardless of need.  This introdu=
ced
> unneeded periodic latency.  This patch offers a better approach.  Usi=
ng code
> provided by Eric Dumazet, we compute the standard deviation of the av=
erage hash
> bucket chain length while running rt_check_expire.  Should any given =
chain
> length grow to larger that average plus 4 standard deviations, we tri=
gger an
> emergency hash table rebuild for that net namespace.  This allows for=
 the common
> case in which chains are well behaved and do not grow unevenly to not=
 incur any
> latency at all, while those systems (which may be being maliciously a=
ttacked),
> only rebuild when the attack is detected.  This patch take 2 other fa=
ctors into
> account:
> 1) chains with multiple entries that differ by attributes that do not=
 affect the
> hash value are only counted once, so as not to unduly bias system to =
rebuilding
> if features like QOS are heavily used
> 2) if rebuilding crosses a certain threshold (which is adjustable via=
 the added
> sysctl in this patch), route caching is disabled entirely for that ne=
t
> namespace, since constant rebuilding is less efficient that no cachin=
g at all
>=20
> Tested successfully by me.
>=20
> Regards
> Neil
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20

Thanks Neil for your patience, this patch is fine.





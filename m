From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Fri, 28 Mar 2008 22:17:26 +0100
Message-ID: <47ED6066.2010407@cosmosbay.com>
References: <47EBC641.8040405@cosmosbay.com> <20080327183745.M9944@visp.net.lb> <47EBEDC9.6080100@cosmosbay.com> <20080327.150308.205829519.davem@davemloft.net> <20080328052543.M60286@visp.net.lb> <47EC8701.1080604@cosmosbay.com> <20080328073854.M73368@visp.net.lb> <47ECA24C.10803@cosmosbay.com> <47ED1583.5010204@cosmosbay.com> <20080328132359.15573601@speedy> <20080328203358.M8487@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:35888
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756420AbYC1VSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:18:35 -0400
In-Reply-To: <20080328203358.M8487@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko a =C3=A9crit :
> It seems or patch change something (but it is just showing debug, str=
ange),=20
> or there is something fixed between 2.6.25-rc7-git1 and 2.6.25-rc7-gi=
t3. LC-
> trie working fine, HASH also i cannot see any leaks.

Yes, the fix is the patch we mentioned yesterday, and you told us you t=
ried it :(

commit 7c0ecc4c4f8fd90988aab8a95297b9c0038b6160

[ICMP]: Dst entry leak in icmp_send host re-lookup code (v2).

Commit 8b7817f3a959ed99d7443afc12f78a7e1fcc2063 ([IPSEC]: Add ICMP host
relookup support) introduced some dst leaks on error paths: the rt
pointer can be forgotten to be put. Fix it bu going to a proper label.

=46ound after net namespace's lo refused to unregister :) Many thanks t=
o
Den for valuable help during debugging.

Herbert pointed out, that xfrm_lookup() will put the rtable in case
of error itself, so the first goto fix is redundant.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: Denis V. Lunev <den@openvz.org>
Signed-off-by: David S. Miller <davem@davemloft.net>

>=20
> I  will have to wait 5-6 hours to make sure. After this time pass, if=
 i will=20
> not see bug again, i will try to run kernel just with default debug l=
ike=20
> before.
>=20
> If it is required, i can test performance and cpu load with/without r=
outing=20
> cache on real workload. Sure it is better to have syntetic tests befo=
re that.


From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Wed, 22 Apr 2009 07:15:15 +0200
Message-ID: <49EEA7E3.3080507@cosmosbay.com>
References: <20090421193937.GC9577@hmsreliant.think-freely.org> <49EE257B.6090600@cosmosbay.com> <20090421200958.GD9577@hmsreliant.think-freely.org> <49EE307D.7050409@cosmosbay.com> <20090421230358.GA13660@hmsreliant.think-freely.org> <20090422011214.GA18856@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48120 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbZDVFP3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 01:15:29 -0400
In-Reply-To: <20090422011214.GA18856@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> Hey all-
> 	New patch, taking Erics commentary pointing out my prior stupidity i=
nto
> account :).
>=20
>=20
> The IP MIB (RFC 4293) defines stats for InOctets, OutOctets, InMcastO=
ctets and
> OutMcastOctets:
> http://tools.ietf.org/html/rfc4293
> But it seems we don't track those in any way that easy to separate fr=
om other
> protocols.  This patch adds those missing counters to the stats file.=
  Tested
> successfully by me

Well, looking now at the patch again, I think you cannot add new fields
without breaking existing apps. My previous review stoped at this _BH t=
hing
wihthout looking further :)

Also, it seems some RFC4293 items are already handled, since commit d83=
1666e
from Mitsuru Chinen. Check net/ipv4/proc.c, line 114

/* Following RFC4293 items are displayed in /proc/net/netstat */
static const struct snmp_mib snmp4_ipextstats_list[] =3D {
        SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
        SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS),
        SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
        SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
        SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
        SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
        SNMP_MIB_SENTINEL
};


# grep IpExt /proc/net/netstat
IpExt: InNoRoutes InTruncatedPkts InMcastPkts OutMcastPkts InBcastPkts =
OutBcastPkts
IpExt: 0 0 0 0 5089 0

So you might add items after existing ones, in IpExt preferably, in ord=
er not
breaking old applications.


Thanks



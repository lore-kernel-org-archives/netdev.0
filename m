From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Wed, 21 Oct 2009 21:54:55 +0200
Message-ID: <4ADF670F.1010200@gmail.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091021165139.GL877@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37723 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668AbZJUTy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 15:54:57 -0400
In-Reply-To: <20091021165139.GL877@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise a =E9crit :
> On Wed, Oct 21, 2009 at 05:40:07PM +0200, Eric Dumazet wrote:
>> Ben patch only address interface deletion, and one part of the probl=
em,
>> maybe the more visible one for the current kernel.
>=20
> The first part I've been tackling has been the overhead in procfs, sy=
sctl=20
> and sysfs.  I've got patches for some of the issues, hacks for others=
, and=20
> should have something to post in a few days.  Getting rid of those ov=
erheads=20
> is enough to get to decent interface creation times for the first 20 =
or 30k=20
> interfaces.
>=20
> On the interface deletion side of things, within the network code, fi=
b_hash=20
> has a few linear scans that really start hurting.  trie is a bit bett=
er,=20
> but I haven't started digging too deeply into its flush/remove overhe=
ad yet,=20
> aside from noticing that trie has a linear scan if=20
> CONFIG_IP_ROUTE_MULTIPATH is set since it sets the hash size to 1. =20
> fn_trie_flush() is currently the worst offender during deletion.

Well, there are many things to change...

# ip -o link | wc -l
13097
# time ip -o link show mv22248
13045: mv22248@eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DO=
WN \    link/ether 00:1e:0b:8e:c8:08 brd ff:ff:ff:ff:ff:ff

real    0m0.840s
user    0m0.473s
sys     0m0.368s

almost one second to get link status of one particular interface :(

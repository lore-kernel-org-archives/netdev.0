From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name lookups
Date: Tue, 03 Nov 2009 23:06:14 +0100
Message-ID: <4AF0A956.5020600@gmail.com>
References: <20091101163130.GA7911@kvack.org> <20091103035058.GA19515@kroah.com> <20091103200155.GQ8227@kvack.org> <m1my338fbi.fsf@fess.ebiederm.org> <m1y6mn708g.fsf@fess.ebiederm.org> <20091103215650.GT8227@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47418 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754604AbZKCWGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 17:06:16 -0500
In-Reply-To: <20091103215650.GT8227@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise a =E9crit :
> On Tue, Nov 03, 2009 at 01:43:43PM -0800, Eric W. Biederman wrote:
>> I guess in particular what I would expect is that if we can do 35000
>> interfaces in 63s with an O(N^2) algorithm.  Then we should be able =
to
>> do 35000 interfaces with an O(NlogN) algorithm in under a second.
>> Which for your application should make the time essentially flat in
>> the number of interfaces.
>=20
> That's the wrong way to interprete the numbers.  The 35000 number of =
63s is=20
> the time that it takes 63s to add 5000 more interfaces in the 30,000 =
to=20
> 35,000 range.  This includes the time required to add a point to poin=
t ip=20
> route on the interface and bring the interface up.

Speaking of pppol2tp, it seems /proc/net/pppol2tp is not safe,
with a strange two phases locking...

(We keep in struct pppol2tp_seq_data pointers to structures
that might have been freed between to read() syscalls)

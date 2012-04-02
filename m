From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Mon, 02 Apr 2012 17:40:06 -0400 (EDT)
Message-ID: <20120402.174006.70116829696492189.davem@davemloft.net>
References: <1333398660-11552-1-git-send-email-levinsasha928@gmail.com>
	<201204022201.41808.remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: levinsasha928@gmail.com, remi.denis-courmont@nokia.com,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: remi@remlab.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204022201.41808.remi@remlab.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "R=E9mi Denis-Courmont" <remi@remlab.net>
Date: Mon, 2 Apr 2012 22:01:40 +0300

> Le lundi 2 avril 2012 23:31:00 Sasha Levin, vous avez =E9crit :
>> A phonet packet is limited to USHRT_MAX bytes, this is never checked=
 during
>> tx which means that the user can specify any size he wishes, and the=
 kernel
>> will attempt to allocate that size.
>=20
> Does this really solve the problem?  I guess 128kb is still possible =
with=20
> USHRT_MAX plus skbuff overhead, which might still trigger OOM relativ=
ely=20
> easily once the memory gets sufficiently fragmented.
>=20
> How does UDP deal with this?

UDP generates a fragment list of MTU sized SKBs.

Phonet could avoid the large allocations by building page based
SKBs.

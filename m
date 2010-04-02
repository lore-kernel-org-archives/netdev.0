From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: Fix several rcu_dereference() calls used
 without RCU read locks
Date: Thu, 01 Apr 2010 17:27:21 -0700 (PDT)
Message-ID: <20100401.172721.144384691.davem@davemloft.net>
References: <20100401204357.9795.80383.stgit@flek.lan>
	<1270155407.2192.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paul.moore@hp.com, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753374Ab0DBA1U convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 20:27:20 -0400
In-Reply-To: <1270155407.2192.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Apr 2010 22:56:47 +0200

> Le jeudi 01 avril 2010 =E0 16:43 -0400, Paul Moore a =E9crit :
>> The recent changes to add RCU lock verification to rcu_dereference()=
 calls
>> caught out a problem with netlbl_unlhsh_hash(), see below.
>>=20
>>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>>  [ INFO: suspicious rcu_dereference_check() usage. ]
>>  ---------------------------------------------------
>>  net/netlabel/netlabel_unlabeled.c:246 invoked rcu_dereference_check=
()
>>  without protection!
>>=20
>> This patch fixes this problem as well as others like it in the NetLa=
bel
>> code.  Also included in this patch is the identification of future w=
ork
>> to eliminate the RCU read lock in netlbl_domhsh_add(), but in the in=
terest
>> of getting this patch out quickly that work will happen in another p=
atch
>> to be finished later.
>>=20
>> Thanks to Eric Dumazet and Paul McKenney for their help in understan=
ding
>> the recent RCU changes.
>>=20
>> Signed-off-by: Paul Moore <paul.moore@hp.com>
>> Reported-by: David Howells <dhowells@redhat.com>
>> CC: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>> ---
>>  net/netlabel/netlabel_domainhash.c |   28 ++++++++++-----
>>  net/netlabel/netlabel_unlabeled.c  |   66 ++++++++++---------------=
-----------
>>  2 files changed, 37 insertions(+), 57 deletions(-)
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

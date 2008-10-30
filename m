From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] udp: Introduce special NULL pointers for hlist termination
Date: Thu, 30 Oct 2008 18:12:03 +0100
Message-ID: <4909EAE3.9060002@cosmosbay.com>
References: <4908627C.6030001@acm.org>	<490874F2.2060306@cosmosbay.com>	<49088288.6050805@acm.org>	<49088AD1.7040805@cosmosbay.com>	<20081029163739.GB6732@linux.vnet.ibm.com>	<49089BE5.3090705@acm.org>	<4908A134.4040705@cosmosbay.com>	<4908AB3F.1060003@acm.org>	<20081029185200.GE6732@linux.vnet.ibm.com>	<4908C0CD.5050406@cosmosbay.com>	<20081029201759.GF6732@linux.vnet.ibm.com>	<4908DEDE.5030706@cosmosbay.com>	<4909D551.9080309@cosmosbay.com> <20081030085126.0d9b956b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37709 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755378AbYJ3RST convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 13:18:19 -0400
In-Reply-To: <20081030085126.0d9b956b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> On Thu, 30 Oct 2008 16:40:01 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:

>>
>> [PATCH] udp: Introduce special NULL pointers for hlist termination
>>
>> In order to safely detect changes in chains, we would like to have d=
ifferent
>> 'NULL' pointers. Each chain in hash table is terminated by an unique=
 'NULL'
>> value, so that the lockless readers can detect their lookups evaded =
from
>> their starting chain.
>>
>> We introduce a new type of hlist implementation, named hlist_nulls, =
were
>> we use the least significant bit of the 'ptr' to tell if its a "NULL=
" value
>> or a pointer to an object. We expect to use this new hlist variant f=
or TCP
>> as well.
>>
>> For UDP/UDP-Lite hash table, we use 128 different "NULL" values,
>> (UDP_HTABLE_SIZE=3D128)
>>
>> Using hlist_nulls saves memory barriers (a read barrier to fetch 'ne=
xt'
>> pointers *before* checking key values) we added in commit=20
>> 96631ed16c514cf8b28fab991a076985ce378c26
>> (udp: introduce sk_for_each_rcu_safenext())
>>
>> This also saves a write memory barrier in udp_lib_get_port(), betwee=
n
>> sk->sk_hash update and sk->next update)
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> ---
>=20
> IMHO this goes over the edge into tricky hack. Is it really worth it?
> Is there a better simpler way?

rwlocks , spinlocks, seqlocks :)

More seriously Stephen, if the infrastructure is clean, and well tested=
 on a relative
simple case (UDP), it can then be deployed on a much more interesting p=
rotocol : TCP

The moment we switch to RCU, we have to accept the pain of really under=
stand what
we did. Details are scary yes.



From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Thu, 30 Oct 2008 12:29:16 +0100
Message-ID: <49099A8C.8030709@cosmosbay.com>
References: <20081008.114527.189056050.davem@davemloft.net>	 <49077918.4050706@cosmosbay.com>	<490795FB.2000201@cosmosbay.com>	 <20081028.220536.183082966.davem@davemloft.net>	 <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com>	 <4908627C.6030001@acm.org>  <490874F2.2060306@cosmosbay.com> <1225365126.7803.66.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com,
	Christoph Lameter <cl@linux-foundation.org>,
	johnpol@2ka.mipt.ru, Christian Bell <christian@myri.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39881 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbYJ3LaB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 07:30:01 -0400
In-Reply-To: <1225365126.7803.66.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra a =E9crit :
> On Wed, 2008-10-29 at 15:36 +0100, Eric Dumazet wrote:
>> +/**
>> + * hlist_for_each_entry_rcu_safenext - iterate over rcu list of giv=
en type
>> + * @tpos:      the type * to use as a loop cursor.
>> + * @pos:       the &struct hlist_node to use as a loop cursor.
>> + * @head:      the head for your list.
>> + * @member:    the name of the hlist_node within the struct.
>> + * @next:       the &struct hlist_node to use as a next cursor
>> + *
>> + * Special version of hlist_for_each_entry_rcu that make sure
>> + * each next pointer is fetched before each iteration.
>> + */
>> +#define hlist_for_each_entry_rcu_safenext(tpos, pos, head, member, =
next) \
>> +       for (pos =3D rcu_dereference((head)->first);                =
       \
>> +               pos && ({ next =3D pos->next; smp_rmb(); prefetch(ne=
xt); 1; }) && \
>> +               ({ tpos =3D hlist_entry(pos, typeof(*tpos), member);=
 1; }); \
>> +               pos =3D rcu_dereference(next))
>> +
>=20
> why _safenext and not _safe like hlist_for_each_entry_safe() which al=
so
> keeps a next pointer?
>=20
> Also note the difference in argument order between these two.
>=20

Yes, this one is going to vanish soon.



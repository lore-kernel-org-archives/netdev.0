From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses	dev_addr_list
 (v3)
Date: Sat, 18 Apr 2009 09:35:32 +0200
Message-ID: <49E982C4.8020407@cosmosbay.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090415081720.GA21342@psychotron.englab.brq.redhat.com> <20090415081819.GB21342@psychotron.englab.brq.redhat.com> <20090415180215.GA22540@psychotron.englab.brq.redhat.com> <20090417115723.GE9556@psychotron.englab.brq.redhat.com> <20090417083315.2f089755@nehalam> <20090418070151.GA3370@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33127 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbZDRHgO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 03:36:14 -0400
In-Reply-To: <20090418070151.GA3370@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko a =E9crit :
> Fri, Apr 17, 2009 at 05:33:15PM CEST, shemminger@vyatta.com wrote:
>=20
> <snip>
>=20
>>> +struct netdev_hw_addr {
>>> +	struct list_head	list;
>>> +	unsigned char		addr[MAX_ADDR_LEN];
>>> +	int			refcount;
>>> +	struct rcu_head		rcu_head;
>>> +};
>> Minor nit, the ordering of elements cause holes that might not be
>> needed.
>=20
> Agree that ordering might be done better. Will do.
>> Space saving? is rcu_head needed or would using synchronize_net
>> make code cleaner and save space.=20
>>
>=20
> Well I originaly had this done by synchronize_rcu(). Eric argued that=
 it might
> cause especially __hw_addr_del_multiple_ii() to run long and suggeste=
d to use
> call_rcu() instead. I plan to switch this to kfree_rcu() (or whatever=
 it's
> called) once it hits the tree.
>=20

Yes, and dont forget we wont save space, as we allocate a full
cache line to hold a 'struct netdev_hw_addr', since we dont want this
critical and read_mostly object polluted by a hot spot elsewhere in ker=
nel...

Considering this, letting 'rcu_head' at the end of structure, even if w=
e
have an eventual hole on 64 bit arches is not really a problem, and IMH=
O
the best thing to do, as rcu_head is only used at dismantle time.

And yes, maybe kfree_rcu() will makes its way in kernel, eventually :)

Thank you



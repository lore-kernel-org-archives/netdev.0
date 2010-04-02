From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 10/12] l2tp: Add L2TP ethernet pseudowire support
Date: Fri, 02 Apr 2010 17:58:51 +0200
Message-ID: <1270223931.11099.7.camel@edumazet-laptop>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>
	 <20100330161819.9628.10853.stgit@bert.katalix.com>
	 <20100330093252.60d9cbee@nehalam> <4BB31761.2090906@katalix.com>
	 <20100331173836.GG2461@linux.vnet.ibm.com>
	 <20100402152402.GA6017@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Chapman <jchapman@katalix.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:42307 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab0DBP65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 11:58:57 -0400
Received: by bwz9 with SMTP id 9so1700089bwz.29
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 08:58:55 -0700 (PDT)
In-Reply-To: <20100402152402.GA6017@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 avril 2010 =C3=A0 08:24 -0700, Paul E. McKenney a =C3=A9=
crit :
> On Wed, Mar 31, 2010 at 10:38:36AM -0700, Paul E. McKenney wrote:

> > The list_is_last() is RCU-safe already, since the ->next pointer is
> > only compared, never dereferenced.  I suggest adding a comment to i=
ts
> > header stating that it is RCU-safe.
> >=20
> > Feel free to create a list_for_each_entry_safe_rcu(), and I will be
> > happy to review it.
>=20
> Right.  When using RCU, list_for_each_entry_safe_rcu() is not needed,
> because destruction of the element you removed doesn't happen until t=
he
> end of a subsequent grace period.  By which time you will be done wit=
h
> your RCU read-side critical section.
>=20
> So you can just use list_for_each_entry_rcu(), you do not need a new
> list_for_each_entry_safe_rcu().
>=20
> But you did have me going for a bit!!!  ;-)

Just wondering Paul if you need to rest :)

list_for_each_entry_safe_rcu() is not needed not because of various (an=
d
very intersting) reasons you gave !!!

But because list_for_each_entry_safe() is OK, since if we are in a
destroy phase, we are a writer, and can use regular list primitive.

Remember _rcu() versions of list iterators are for readers, and readers
are NOT supposed to delete an item from the list !

Eric




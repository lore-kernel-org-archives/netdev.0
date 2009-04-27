From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Question about locks in qdisc_restart
Date: Mon, 27 Apr 2009 22:20:29 +0200
Message-ID: <49F6138D.6090007@cosmosbay.com>
References: <65634d660904271248p133717aam55751fc435f9fd3e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35353 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbZD0UUg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 16:20:36 -0400
In-Reply-To: <65634d660904271248p133717aam55751fc435f9fd3e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
> In qdisc_restart the qdisc lock is released before taking the
> netif_tx_lock, and only acquired again after unlocking the
> netif_tx_lock.  There's a comment with the function that
> "qdisc_lock(q) and netif_tx_lock are mutually exclusive, if one is
> grabbed, another must be free."  Can anyone tell me the motivation fo=
r
> this restriction?  We are seeing some performance improvements by
> holding the lock through qdisc_restart, and I'm not sure why this
> would be bad to do.
>=20

Well, motivation is to let other users (cpus) have a chance getting the=
 lock :)

Do you see performance improvements too if using spin_is_contended()
to break the __qdisc_run loop ?

if (need_resched() || jiffies !=3D start_time || spin_is_contended(qdis=
c_lock(q))

(And removing the unlock/lock in qdisc_restart() as you did)


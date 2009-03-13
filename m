From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Fri, 13 Mar 2009 23:45:07 +0100
Message-ID: <49BAE1F3.5020105@cosmosbay.com>
References: <49B4B909.7050002@cosmosbay.com>	<20090313.145152.121603300.davem@davemloft.net>	<49BADE87.40407@cosmosbay.com> <20090313.153851.11725991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	cl@linux-foundation.org, bmb@athenacr.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38546 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997AbZCMWqW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 18:46:22 -0400
In-Reply-To: <20090313.153851.11725991.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 13 Mar 2009 23:30:31 +0100
>=20
>> David Miller a =E9crit :
>>>> Also, when an event was queued for later invocation, I also needed=
 to keep
>>>> a reference on "struct socket" to make sure it doesnt disappear be=
fore
>>>> the invocation. Not all sockets are RCU guarded (we added RCU only=
 for=20
>>>> some protocols (TCP, UDP ...). So I found keeping a read_lock
>>>> on callback was the easyest thing to do. I now realize we might
>>>> overflow preempt_count, so special care is needed.
>>> You're using this in UDP so... make the rule that you can't use
>>> this with a non-RCU-quiescent protocol.
>> UDP/TCP only ? I though many other protocols (not all using RCU) wer=
e
>> using sock_def_readable() too...
>=20
> Maybe create a inet_def_readable() just for this purpose :-)

I must be tired, I should had this idea before you :)

I post a new patch after some rest, I definitly should not be still awa=
ke !



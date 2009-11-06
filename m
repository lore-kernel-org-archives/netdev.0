From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH net-next] Phonet: use rwlock for sockets list
Date: Fri, 06 Nov 2009 14:54:38 +0100
Message-ID: <65081524fbfeb975c842ebc79a8fb038@chewa.net>
References: <1257514891-18917-1-git-send-email-remi@remlab.net> <4AF42834.7010707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?Q?R=C3=A9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:60970 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbZKFNye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 08:54:34 -0500
In-Reply-To: <4AF42834.7010707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 06 Nov 2009 14:44:20 +0100, Eric Dumazet <eric.dumazet@gmail.co=
m>=0D
wrote:=0D
> R=C3=A9mi Denis-Courmont a =C3=A9crit :=0D
>> From: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>=0D
>>=0D
>> Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.c=
om>=0D
>> ---=0D
>>  net/phonet/socket.c |   24 ++++++++++++------------=0D
>>  1 files changed, 12 insertions(+), 12 deletions(-)=0D
> =0D
> Hmm... rwlocks are bad...=0D
=0D
They're in many places throughout the non-IP families...=0D
=0D
> Would you care to explain why you introduce a rwlock ?=0D
=0D
It seems better than a spinlock, assuming that sockets are=0D
created/destroyed more seldom than they receive packets. And then=0D
sk_for_each_rcu does not exist. I am sure there is a good reason for th=
at,=0D
though I wouldn't know. I guess I should try to use RCU hlist_nulls the=
n?=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont


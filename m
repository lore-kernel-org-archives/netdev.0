From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Fri, 26 Jun 2009 21:35:28 +0200
Message-ID: <4A452300.5080507@gmail.com>
References: <alpine.DEB.1.10.0906261018580.16400@makko.or.mcafeemobile.com>	<20090626145027.GA6534@redhat.com>	<alpine.DEB.1.10.0906261111230.16400@makko.or.mcafeemobile.com> <20090626.111738.141246987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, davidel@xmailserver.org,
	oleg@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	htejun@gmail.com
To: jolsa@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47353 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931AbZFZTgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 15:36:31 -0400
In-Reply-To: <20090626.111738.141246987.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Davide Libenzi <davidel@xmailserver.org>
> Date: Fri, 26 Jun 2009 11:12:15 -0700 (PDT)
>=20
>> On Fri, 26 Jun 2009, Oleg Nesterov wrote:
>>
>>> Perhaps we can add
>>>
>>> 	void sock_poll_wait(struct file *file, struct sock *sk, poll_table=
 *pt)
>>> 	{
>>> 		if (pt) {
>>> 			poll_wait(file, sk->sk_sleep, pt);
>>> 			/*
>>> 			 * fat comment
>>> 			 */
>>> 			smp_mb(); // or smp_mb__after_unlock();
>>> 		}
>>> 	}
>> That'd be fine IMHO. Are DaveM and Eric OK?
>=20
> No objections from me.

Very good :)

Jiri, please respin a patch with this idea from Oleg

(We'll have to check all calls to poll_wait() in net tree)

Thanks everybody


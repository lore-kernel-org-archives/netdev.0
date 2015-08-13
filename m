From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] inet: fix races with reqsk timers
Date: Fri, 14 Aug 2015 00:13:24 +0300
Message-ID: <2FC70745-2105-465E-A82E-44D565A930F0@cumulusnetworks.com>
References: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com> <20150810.211821.2246516216165801977.davem@davemloft.net> <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com> <1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36264 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbHMVN1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 17:13:27 -0400
Received: by wicja10 with SMTP id ja10so164128137wic.1
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 14:13:25 -0700 (PDT)
In-Reply-To: <1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 13, 2015, at 11:44 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>=20
> On Thu, 2015-08-13 at 13:19 -0700, Eric Dumazet wrote:
>=20
>>=20
>> A caller handler can not call del_timer_sync()
>=20
> A timer handler can not call del_timer_sync()
>=20
> I am testing a minimal fix :
>=20
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
> index 05e3145f7dc3..134957159c27 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -593,7 +593,7 @@ static bool reqsk_queue_unlink(struct request_soc=
k_queue *queue,
> 	}
>=20
> 	spin_unlock(&queue->syn_wait_lock);
> -	if (del_timer_sync(&req->rsk_timer))
> +	if (timer_pending(&req->rsk_timer) && del_timer_sync(&req->rsk_time=
r))
> 		reqsk_put(req);
> 	return found;
> }
>=20
>=20

Wouldn=E2=80=99t try_to_del_timer_sync(&req->rsk_timer) > 0 be better ?

From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] xmit_compl_seq: information to reclaim vmsplice buffers
Date: Mon, 20 Sep 2010 10:50:22 -0700
Message-ID: <AANLkTi=53F3O511Uq83dP75brGkJMgN_-OR9W0VJS1p-@mail.gmail.com>
References: <alpine.DEB.1.00.1009191451090.5120@pokey.mtv.corp.google.com>
	<AANLkTinyZxF4ep7tv_uSpcPD8gfNoddX6G7p+ZuA2ze9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, sridharr@google.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:28778 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab0ITRuk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 13:50:40 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o8KHoOhV011398
	for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 10:50:25 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by wpaz33.hot.corp.google.com with ESMTP id o8KHo1K3028779
	for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 10:50:22 -0700
Received: by pzk4 with SMTP id 4so2199325pzk.35
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 10:50:22 -0700 (PDT)
In-Reply-To: <AANLkTinyZxF4ep7tv_uSpcPD8gfNoddX6G7p+ZuA2ze9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> > Using recvmsg data in this manner is sort of a cheap way to get a
> > "callback" for when a vmspliced buffer is consumed. =A0It will work
> > well for a client where the response causes recvmsg to return.
>
> In this case, we don't need it. The response is sufficient to indicat=
e
> the request is sent out, and the corresponding pages are available fo=
r
> the other use.

The response might seem sufficient, but there is no guarantee this
works generally for every application protocol.=A0 The specific
requirement for TCP is that the page cannot be reused before its data
has been acked; if this does not hold then data corruption becomes an
issue.=A0 Given that danger, I would rather the mechanism be unambiguou=
s
about when the data has been consumed, rather than each application
protocol trying to figure this out using its heuristics.

>
> > On the server side it works well if there are a sufficient
> > number of requests coming on the connection (resorting to the
> > timeout if necessary as described above).
>
> If no response is sent out by the client, the timeout mechanism may
> slow down the data transfer.
>
Why would that slow down a transfer?

>
> I think we should not mix RX and TX. Maybe we can add a new epoll
> event to indicate that the snd bufer is advanced.
>
This is possible, but seems more heavyweight that needed.=A0 I don't se=
e
that it's going to be critical to reclaim buffers as soon as they have
been completed, some laziness in do this seems like a reasonable
tradeoff and we should still have a reasonable working set.

Tom

> --
> Regards,
> Changli Gao(xiaosuo@gmail.com)

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] ipv4: Create probe timer for tcp PMTU as
 per RFC4821
Date: Mon, 16 Feb 2015 04:19:54 -0800
Message-ID: <1424089194.4942.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
	 <1423815405-32644-4-git-send-email-fan.du@intel.com>
	 <1423830709.4942.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54E18263.8040002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:35878 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303AbbBPMT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 07:19:57 -0500
Received: by mail-qa0-f54.google.com with SMTP id x12so21823090qac.13
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 04:19:57 -0800 (PST)
In-Reply-To: <54E18263.8040002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-16 at 13:38 +0800, Fan Du wrote:
> =E4=BA=8E 2015=E5=B9=B402=E6=9C=8813=E6=97=A5 20:31, Eric Dumazet =E5=
=86=99=E9=81=93:

> > We certainly wont add yet another timer in tcp socket for such usag=
e.
> >
> > And a buggy one, since you forgot all the refcounting associated wi=
th
> > such timers.
>=20
> oh, embarrassing...
> Will place probe timer aside with icsk_delack_timer in struct inet_co=
nnection_sock,
> and manipulate through sk_reset_timer.

No : I said we would _not_ accept yet another timer (ie a big structure=
)
for such very rare event.

You can implement a pseudo timer, using a simple u32 field, that you
test in tcp_mtu_probe() to clear icsk->icsk_mtup.probe_size when enough
time has elapsed.

(tcp_time_stamp is u32, so are tp->lsndtime, tp->snd_cwnd_stamp,=20
tp->rcv_tstamp, tp->retrans_stamp, tp->tso_deferred, ...)

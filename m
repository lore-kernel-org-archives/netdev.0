From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 10:58:26 +0200
Message-ID: <1271321906.16881.2257.camel@edumazet-laptop>
References: <u2o412e6f7f1004150047nc9250ffuaef68be066a7575c@mail.gmail.com>
	 <20100415.005726.205428265.davem@davemloft.net>
	 <k2y412e6f7f1004150127u4e7ec668r80f066bfb3efea81@mail.gmail.com>
	 <20100415.013347.98375530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, therbert@google.com, eparis@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:54375 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757449Ab0DOI6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:58:36 -0400
Received: by bwz25 with SMTP id 25so1218059bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 01:58:35 -0700 (PDT)
In-Reply-To: <20100415.013347.98375530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 01:33 -0700, David Miller a =C3=A9crit :

> Yes, this looks more reasonable.  Eric if you agree please (re-)submi=
t
> this formally, I must have missed this somehow, sorry.
>=20
> And this is a bug fix in any kernel, not just one's that have RPS
> patches applied.
>=20
> If we are not called from some interrupt context, there is no sure
> trigger to make sure software interrupts will be executed after the
> packet is queued locally.  netif_rx_ni() makes sure that any pending
> software interrupts will run in such cases.

Our mails crossed ;)

Yes I think it's more reasonable to fix it like this, I'll submit a
patch after fully testing it :)




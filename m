From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Tue, 13 Apr 2010 16:37:42 +0200
Message-ID: <1271169462.16881.428.camel@edumazet-laptop>
References: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
	 <1271146112.16881.213.camel@edumazet-laptop>
	 <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
	 <1271153942.16881.233.camel@edumazet-laptop>
	 <n2t412e6f7f1004130553x85452fc0u22e512cad412abd3@mail.gmail.com>
	 <1271164894.16881.342.camel@edumazet-laptop>
	 <x2z412e6f7f1004130638hb72b121cne442d722427de5a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:45757 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966Ab0DMOhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 10:37:52 -0400
Received: by bwz19 with SMTP id 19so18164bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 07:37:50 -0700 (PDT)
In-Reply-To: <x2z412e6f7f1004130638hb72b121cne442d722427de5a4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 21:38 +0800, Changli Gao a =C3=A9crit :
> On Tue, Apr 13, 2010 at 9:21 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > This is a problem of cooperation between flush_backlog() and
> > process_backlog(). Dont allow flush_backlog() to return if
> > process_backlog() is running. Exactly as before, but lock acquisiti=
on
> > done in flush_backlog() should be a bit smarter.
> >
>=20
> flush_backlog() is called in IRQ context. Unless you disable irq in
> process_backlog(), you can't block flush_backlog().
>=20

There is nothing preventing flush_backlog() to be done differently you
know. It was done like that because it was the most simple thing to do
given the (basic) constraints. Now if the constraints change,
implementation might change too. It is slow path (in most setups) and
some extra work to keep fast path really fast is ok.

netdevice are dismantled and we respect an RCU grace period before
freeing. process_backlog() is done inside a rcu lock, so everything is
possible.




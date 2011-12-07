From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Wed, 07 Dec 2011 14:04:39 +0100
Message-ID: <1323263079.2312.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <9bf91034-a860-4144-858b-c9000964ea1d@jasiiieee>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:33612 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755060Ab1LGNEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 08:04:45 -0500
Received: by lagp5 with SMTP id p5so194905lag.19
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2011 05:04:43 -0800 (PST)
In-Reply-To: <9bf91034-a860-4144-858b-c9000964ea1d@jasiiieee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 d=C3=A9cembre 2011 =C3=A0 14:44 -0500, John A. Sullivan III=
 a =C3=A9crit :
> Interesting.  Would that still be true if all the traffic is the same=
,
> i.e., nothing but iSCSI packets on the network? Or would just dumping
> packets with minimal processing be fastest? Thanks - John

Dave focuses on fairness and latencies under ~20 ms (a typical (under)
provisioned ADSL (up)link shared by many (hostile) flows, with various
type of services)

I doubt this is your concern ? You want high throughput more than low
latencies ...

Your workload is probably under _one_ ms latencies, and dedicated link
to address few targets.

If you have to use a Qdisc (and expensive packet classification), then
something is wrong in your iSCSI network connectivity :)

Please note that with BQL, the NIC TX ring size doesn=E2=80=99t matter,=
 and you
could get "Virtual device ethX asks to queue packet!" warnings in your
message log.

So before removing Qdisc, you also want to make sure BQL is disabled fo=
r
your NIC device/queues.
(BQL is scheduled for linux-3.3)

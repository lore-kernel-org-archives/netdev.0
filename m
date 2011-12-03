From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SYN attack, with FIN flag set
Date: Sat, 03 Dec 2011 08:27:13 +0100
Message-ID: <1322897233.2762.79.camel@edumazet-laptop>
References: <1755dc626dee301261ef4fe4cd66fd47@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43028 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab1LCH1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 02:27:18 -0500
Received: by wgbdr13 with SMTP id dr13so2765044wgb.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 23:27:16 -0800 (PST)
In-Reply-To: <1755dc626dee301261ef4fe4cd66fd47@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 03 d=C3=A9cembre 2011 =C3=A0 00:29 +0200, Denys Fedoryshchenk=
o a =C3=A9crit :
> Hi
>=20
>  Recently i started to get SYN attacks, and managed them.
>  syncookies didn't helped, here is "perf report" info:
>  -     26.89%        swapper  [kernel.kallsyms]     [k] _raw_spin_loc=
k
>     - _raw_spin_lock
>        - 94.97% tcp_v4_rcv
>             ip_local_deliver_finish
>             ip_local_deliver
>             ip_rcv_finish
>             ip_rcv
>             __netif_receive_skb
>             process_backlog
>             net_rx_action
>             __do_softirq
>             call_softirq
>             do_softirq
>           + irq_exit
>=20
>  But then i got attack that made server to choke and bypassed "--syn"=
=20
>  rule, and i was surprised, that stack are handling invalid combinati=
on=20
>  of flags, SYN+FIN.
>  Is it valid behaviour?
>=20
>  in tcp_input.c, tcp_rcv_state_process(), it just does check for rst =
(to=20
>  discard), but maybe packet with fin set should be discarded too?

I believe netfilter tcp conntrack considers SYN|FIN as INVALID

Yes, we could drop SYN|FIN messages, but what prevents attacker to just
use SYN messages to attack your machine ?

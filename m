From: Lutz Vieweg <lvml@5t9.de>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp cache
Date: Thu, 16 Mar 2017 12:31:25 +0100
Message-ID: <58CA778D.9020208@5t9.de>
References: <20170315203046.158791-1-soheil.kdev@gmail.com> <20170315.154044.170788541865531834.davem@davemloft.net> <20170315225508.GB14761@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: soheil.kdev@gmail.com, netdev@vger.kernel.org, soheil@google.com,
        edumazet@google.com, ncardwell@google.com, ycheng@google.com,
        fw@strlen.de
To: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p05-ob.smtp.rzone.de ([81.169.146.183]:24967 "EHLO
        mo4-p05-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751478AbdCPLhf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 07:37:35 -0400
In-Reply-To: <20170315225508.GB14761@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/15/2017 11:55 PM, Willy Tarreau wrote:
> At least I can say I've seen many people enable it without understandin=
g its impact, confusing it
> with tcp_tw_reuse, and copy-pasting it from random blogs and complainin=
g about issues in
> production.

I currently wonder: What it the correct advise to an operator who needs
to run one server instance that is meant to accept thousands of new,
short-lived TCP connections per minute?

The explanation text at
https://vincent.bernat.im/en/blog/2014-tcp-time-wait-state-linux
seems to provide comprehensive advise, but its summary is, after all,
somewhat disappointing:

> The universal solution is to increase the number of possible quadruplet=
s by using, for example,
> more server ports. This will allow you to not exhaust the possible conn=
ections with TIME-WAIT
> entries.

Assuming an operator has to deal with a given server executable, which do=
es not
provide a feature to "open many listening ports for the same purpose in p=
arallel",
this is hardly an option. (Of course, if you can start just N instead of =
1 server
instance, this becomes an option, but not everything is a simple, statele=
ss web server.)

> On the server side, do not enable net.ipv4.tcp_tw_recycle unless you ar=
e pretty sure you will
> never have NAT devices in the mix. Enabling net.ipv4.tcp_tw_reuse is us=
eless for incoming
> connections.

So basically both options won't help the server operator.

> On the client side, enabling net.ipv4.tcp_tw_reuse is another almost-sa=
fe solution. Enabling
> net.ipv4.tcp_tw_recycle in addition to net.ipv4.tcp_tw_reuse is mostly =
useless.

If you just operate the server, but not the (remote) clients, this is not=
 relevant.


Is the final verdict that unless a server software by itself offers to op=
en
N listen ports for the same purpose, there is no solution?

Regards,

Lutz Vieweg

From: Joerg Pommnitz <pommnitz@yahoo.com>
Subject: AW: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 02:54:10 -0800 (PST)
Message-ID: <636518.43765.qm@web51402.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51402.mail.re2.yahoo.com ([206.190.38.181]:44560 "HELO
	web51402.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755314AbXK0KyL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 05:54:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek,
this is all about outgoing packets, e.g. egress to use your word.
It doesn't matter whether the packets are originated locally or
whether the packets are forwarded from another host (I tried
both).

To restate the problem: according to my observations the prio qdisc
(and probably pfifo_fast, but I couldn't observe this) does not priorit=
ize
at all and always uses the band indicated by the first entry in the
priomap.

By default the priomap looks like this:
qdisc prio 1: dev eth1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1

there are 3 bands (1:1, 1:2 and 1:3). In theory the traffic should go t=
hrough
the different bands according to the TOS value of the packets. My obser=
vation
is, that the traffic always uses the band pointed to by the first entry=
 in the
priomap. This value is 1 by default, so all traffic goes through band 1=
:2.

Now it's entirely possible that I did something stupid, but nobody came=
 forward
to show me the error of my ways (neither here nor on the lartc list).

-- Regards
=20
       Joerg

----- Urspr=FCngliche Mail ----
Von: Jarek Poplawski <jarkao2@o2.pl>
An: Joerg Pommnitz <pommnitz@yahoo.com>
CC: netdev@vger.kernel.org
Gesendet: Dienstag, den 27. November 2007, 10:58:38 Uhr
Betreff: Re: Does tc-prio really work as advertised?

On Tue, Nov 27, 2007 at 01:28:43AM -0800, Joerg Pommnitz wrote:
> Jarek,
> iptables chains (this is what I think you are referring to) are not  =
the issue.

Yes, but this could (wrongly) look like this according to my 1-st  mess=
age.

> This
> is about the qdisc that sits immediately over the device driver and  =
decides the
> order waiting packets are sent over the line/air/carrier pigeon/... .
> My suspicion is that skb->priority used to be set to a value that  de=
rived from the
> TOS bits. Then something changed and nobody noticed.

I'm not sure of your problem: did you try this on a box which
gets packets with TOS set earlier, does forwarding, and uses this
prio on egress? If so, and this doesn't work, then you are right
something could be wrong.

Regards,
Jarek P.






        __________________________________  Ihr erstes Baby? Holen Sie =
sich Tipps von anderen Eltern.  www.yahoo.de/clever

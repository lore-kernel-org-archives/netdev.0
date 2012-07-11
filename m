From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: UDP ordering when using multiple rx queue
Date: Wed, 11 Jul 2012 09:53:44 +0200
Message-ID: <CAL8zT=g5nHd6FprhxFc21XTgfXeaokt4QN1fS4ekcNVkuvZE9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:39197 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756767Ab2GKHyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 03:54:05 -0400
Received: by wibhm11 with SMTP id hm11so5409118wib.1
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 00:54:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,

I am doing some experiments on several NICs and I have an issue with
my application.
This is a sending of raw data packets which consists of bursts each
1/30s of 784 times 4000 bytes UDP packets.
The packets are one a wired link, no switch or anything, so there is
no chance of reordering or drop between the sender and receiver.

On receiver side, I need to get the packets ordered, or the
application will consider the packets are late (and then, lost).
(Yes, the application is badly written on that specific part, but it
is not mine :)).

Several tests lead to a simple conclusion : when the NIC has only one
RX queue, everything is ok (like be2net for instance), but when it has
more than one RX queue, then I can have "lost packets".
This is the case for bnx2x or mlx4 for instance.

Here are my questions :
- Is it possible to force a driver to use only one rx queue, even if
it can use more without reloading the driver (and this is feasible
only when a parameter exists for that !) ?
- Is it possible to "force" the network stack to give the packets on
the correct order (I would say no, as this is not specified in the
protocol) ?

My only bet is the first one (forcing one rx queue).
The last and desperate solution would be rewriting the application,
not easy to make it accepted.

Thanks !
JM

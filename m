From: Marc Dionne <marc.c.dionne@gmail.com>
Subject: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Mon, 27 Jun 2016 10:41:49 -0300
Message-ID: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:33703 "EHLO
	mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbcF0Nl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 09:41:56 -0400
Received: by mail-vk0-f45.google.com with SMTP id j3so19480746vkb.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 06:41:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been seeing issues with 4.7-rc kernels with some of our
multi-thread test cases.  I've bisected it down to this commit:

  commit 71d8c47fc653711c41bc3282e5b0e605b3727956
  Author: Pablo Neira Ayuso <pablo@netfilter.org>
  Date:   Sun May 1 00:28:40 2016 +0200

      netfilter: conntrack: introduce clash resolution on insertion race


.. and verified that reverting the commit restores the expected behaviour.

The test spins up 30 threads that start communicating simultaneously
with a server at the same target port, using a UDP based protocol over
loopback.  This test is known to easily trigger the insertion race
that the commit is trying to fix - we check for EPERM errors and retry
in that case.

On my usual test rig the test gets about 700Mb/s.  On current
mainline, the result alternates between a somewhat normal number,
something much lower (~150Mb/s), or complete failure following an
internal timeout.

Any thoughts on what may be going on?

Thanks,
Marc

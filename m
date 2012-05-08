From: =?ISO-8859-1?Q?Andreas_Gr=FCnbacher?=
	<andreas.gruenbacher@gmail.com>
Subject: Zero-copy receive from socket into bio
Date: Tue, 8 May 2012 13:02:44 +0200
Message-ID: <CAHpGcMJD18d388cZGJcB8SkSAcQhwJXKJyAWmpRRPJRdrL23sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:61172 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab2EHLCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 07:02:46 -0400
Received: by lbbgm6 with SMTP id gm6so4107743lbb.19
        for <netdev@vger.kernel.org>; Tue, 08 May 2012 04:02:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave and all,

I'm looking into supporting zero-copy receive in drbd again. It's not
clear to me
how to best get the network drivers to receive packets into page
aligned buffers.

In this particular case, the hardware is using the bnx2 and be2net 1Gbps and
10Gbps drivers.

Can you please offer some guidance?

I've already asked about this a year ago, unfortunately with no feedback:

    http://lwn.net/Articles/438406/

Quoting from that posting:

> The basic idea is this: drbd transmits bios via sockets.  An ideal sender
> sends the packet header and data in separate packets, and the network driver
> [supports RX_COPYBREAK and] receives them into separate socket buffers.
> The socket buffers end up aligned properly, and we add them to bios and
> submit them, no copying required.

Thanks a lot,
Andreas

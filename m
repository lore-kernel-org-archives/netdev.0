From: Andy Lutomirski <luto@amacapital.net>
Subject: LRO/GRO and libpcap packet reordering
Date: Thu, 14 Mar 2013 13:37:41 -0700
Message-ID: <CALCETrXT036Aoaum+uUV_Of0AFdUZ3eq0QjMjxiCJR4n8AZRTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:51761 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab3CNUiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 16:38:02 -0400
Received: by mail-ve0-f177.google.com with SMTP id m1so2079802ves.36
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 13:38:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(I'm on Ubuntu's 3.5.0-23, but I haven't seen anything that would
change this behavior in newer kernels.)

I have a myri10ge device that's attached to a port mirror.  It runs
tcpdump.  Most of the traffic I'm capturing has another machine
attached to this switch as an endpoint.  That machine is considerably
faster than the machine doing the capturing.

My captures show nasty artifacts: packets are reodered between a given
flow and the other direction of the same flow.  The nasty case is when
an ACK shows up before the packet that it's acking.  This thoroughly
screws up Wireshark's TCP sequencing analysis.  Turning off LRO and
GRO fixes it.

Clearly, since this interface doesn't actually have an IP address,
there's no good reason to keep GRO and LRO on.  Nonetheless, it would
be nice if GRO didn't coalesce packets when there's an intervening
packing in the other direction on the same flow.  Can this be done
cheaply?

--Andy

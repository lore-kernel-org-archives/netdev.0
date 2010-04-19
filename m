From: Stefan Agner <stefan@agner.ch>
Subject: ep93xx_eth stopps receiving packages
Date: Mon, 19 Apr 2010 17:38:13 +0200
Message-ID: <20100419173813.7750395f4fkkmrk0@limpopo.deheime.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: buytenh@wantstofly.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.deheime.ch ([62.12.167.34]:37130 "EHLO limpopo.deheime.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751729Ab0DSPoI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 11:44:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm using Linux 2.6.32.9 on a technologic systems TS-7250 SBC board, with
the ep93xx_eth driver for networking. On three identical, but independent
systems I noted that the system is unreachable after a while. On a serial
terminal I noted that only the TX counter counts onward, RX stays where it is,
no matter if i try to ping from or to the system. Wireshark tells me exactly
that too: I see helpless ARP requests which gets answered, but no ICMP. The
system doesnt receive the ARP requests, and just sends another one.
With a simple program which sends small packages in a fast pace I can
reproduce the problem after several seconds (additional CPU load seem to
provoke the problem even more). Remove and replug the network cable doesn't
solve the problem, but ifup/down does. I don't see any messages in dmesg,
memory is still available.

Is it a network driver problem or even a network stack problem?

It looks to me like a race condition in the network driver, which can be
triggered by short packets.

What can I do to track the problem further down?

Thanks for hints,
Stefan

----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.


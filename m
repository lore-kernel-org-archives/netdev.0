From: "Jon Nelson" <jnelson@jamponi.net>
Subject: Re: request: via velocity and tg3 help
Date: Thu, 17 Jul 2008 19:31:28 -0500
Message-ID: <cccedfc60807171731p62806095h40b0a2fbf9677d16@mail.gmail.com>
References: <cccedfc60807151733n1c204c73ya4878bc03cba2e26@mail.gmail.com>
	 <20080716211030.GA27803@electric-eye.fr.zoreil.com>
	 <cccedfc60807161435t54ff2559n9bd2b2b5217870ba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:59790 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101AbYGRAbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 20:31:35 -0400
Received: by fg-out-1718.google.com with SMTP id 19so66874fgg.17
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 17:31:32 -0700 (PDT)
In-Reply-To: <cccedfc60807161435t54ff2559n9bd2b2b5217870ba@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Regarding the TG3 troubles:

The kernel is 2.6.25.9 from openSUSE 11.0, but the tg3 driver is rhe
very latest tg3 driver from netdev-2.6 (which is the same as linux-2.6
HEAD).

When I enable jumbo frames the board still *appears* to work but
nobody can communicate with it. The other machines (multiple) in the
network don't see ANY traffic FROM the tg3.  On the machine with the
tg3, tcpdump shows arp requests (from the other machines) and arp
replies.

After much work, I have determined the problem to be a combination of
scatter-gather and jumbo frames. When both are used, the card does not
work correctly. Disabling *either* appears to work but no benefit is
realized until the interface is brought down and back up again.

An "ethtool -t eth0" shows a single failed test (registers). I have a
register dump and anything else anybody might want if this can be
useful in bug-fixing.

I also saw this:

tg3: DEBUG: MAC_TX_STATUS[00000008] MAC_RX_STATUS[00000006]
tg3: DEBUG: RDMAC_STATUS[00000000] WDMAC_STATUS[00000000]
tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2

I'm using this version:

tg3.c:v3.92.1 (June 9, 2008)
the tg3.c sha1sum is 97c198a8152045f2e7da5fe0d702df1cd185cb8d.

-- 
Jon

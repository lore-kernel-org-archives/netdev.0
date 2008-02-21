From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Thu, 21 Feb 2008 18:09:04 +0100
Message-ID: <47BDB030.1050105@gmail.com>
References: <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080219230640.GA2755@ami.dom.local> <47BC4F2C.4000802@katalix.com> <20080220183837.GA2881@ami.dom.local> <47BCABC5.9080204@katalix.com> <20080221085959.GA12944@ff.dom.local> <47BD4A34.7070606@katalix.com> <20080221120829.GB12944@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:36429 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502AbYBURFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 12:05:33 -0500
Received: by nf-out-0910.google.com with SMTP id g13so53035nfb.21
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 09:05:31 -0800 (PST)
In-Reply-To: <20080221120829.GB12944@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 02/21/2008 01:08 PM:
...

> Another, probably simpler way would be to move almost all pppol2tp_xmit
...

Actually, the simplest off all seems to be now this old idea to maybe make
sk_dst_lock globally softirq immune. At least I think it's worth of testing,
to check for these other possible lockdep warnings. It should only need to
change all write_ and read_lock(&sk->sk_dst_lock) in very few places:
include/net/sock.h, include/net/ip6_route.h, and net/ipv6/ipv6_sockglue.c.
This could be tested together with you full _bh locking patch (maybe except
these other changes in pppol2tp_xmit).

Jarek P.


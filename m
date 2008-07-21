From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 05:09:52 +0400
Message-ID: <20080721010952.GA4822@martell.zuzino.mipt.ru>
References: <20080720.104411.81744468.davem@davemloft.net> <alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org> <20080720.180304.51601407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:62343 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754465AbYGUBME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 21:12:04 -0400
Received: by fg-out-1718.google.com with SMTP id 19so538813fgg.17
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2008 18:12:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080720.180304.51601407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > This is the main networking merge for 2.6.27

Looks like multiqueue changes broken netconsole (it remains silent).

Also, I had to enable CONFIG_NET_SCHED=y, otherwise it wouldn't link:

	net/built-in.o: In function `dev_queue_xmit':
	(.text+0x11210): undefined reference to `qdisc_calculate_pkt_len'
	net/built-in.o: In function `__qdisc_destroy':
	sch_generic.c:(.text+0x1ddcd): undefined reference to `qdisc_put_stab'

And finally, boot process hangs after TCP cubic is initialized.

This is net-2.6 tree (175f9c1bba9b825d22b142d183c9e175488b260c)
(tainted with conntracking-in-net-ns changes, though).


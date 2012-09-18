From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: HTB vs CoDel performance
Date: Tue, 18 Sep 2012 17:28:23 +0800
Message-ID: <CAF1ivSZPpBkKk6mfhEu01bz6yP4KgJU8kK6cmeZ9e+kwH=EtiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: networking <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:40728 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1757371Ab2IRJ3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 05:29:12 -0400
Received: from mail-lpp01m010-f46.google.com (mail-lpp01m010-f46.google.com [209.85.215.46])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id D499CDBBFC
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 17:28:27 +0800 (CST)
Received: by lagy9 with SMTP id y9so4794493lag.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 02:28:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm testing htb performance on a gigabit router running 2.6.32 kernel.
Packet path: PC1 ---> Router LAN port ---> Router WAN port ---> PC2

pfifo_fast: 920Mbps
htb: 750Mbps, ~20% drops compared to pfifo_fast

htb tc commands as below,
# tc qdisc add dev eth10 root handle 20: htb default 1
# tc class add dev eth10 parent 20 classid 20:1 htb prio 2 rate
1024Mbit ceil 1024Mbit burst 1281408b cburst 1281408b

The performance drop seems caused by the complex htb enqueue/dequeue algorithm.

I had a quick look at CoDel code, seems it does not have so complex
data structure as HTB.
I'm going to backport CoDel. Is this a good choice?
Can I gain similar performance as pfifo_fast?

Thanks,
Lin Ming

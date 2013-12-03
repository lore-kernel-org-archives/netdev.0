From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v4 1/2] net: sched: tbf: fix calculation of max_size
Date: Tue, 03 Dec 2013 06:51:33 -0800
Message-ID: <1386082293.30495.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386041214-72744-1-git-send-email-yangyingliang@huawei.com>
			 <1386041214-72744-2-git-send-email-yangyingliang@huawei.com>
		 <1386046793.30495.12.camel@edumazet-glaptop2.roam.corp.google.com>
		 <529D8BC7.4050005@huawei.com>
	 <1386058339.30495.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <529DA8C1.4000504@huawei.com> <529DC163.5090403@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:56079 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754703Ab3LCOvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 09:51:35 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so21170443pbc.35
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 06:51:35 -0800 (PST)
In-Reply-To: <529DC163.5090403@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-03 at 19:32 +0800, Yang Yingliang wrote:

> > 
> >>
> >> TSO packet of 64KB -> about 45 frames if MSS=1448, 45*1514 = 68130 bytes
> 
> Maybe MAX_PKT_LEN should be much bigger. Hmm, I'm uncertain how big is the proper value.
> 

Thats the thing : When user is able to compute the appropriate burst and
give precise instructions to the kernel, why tbf would reduce it to
whatever fixed threshold ?

If I set 200000 as a burst, I do not want tbf use 65536 or even less.

If tbf rounds my 200000 to 199800, its fine.

You had problems to set burst to appropriate values, but most other
users did that fine.

tbf_segment() is an attempt to help for very low rates, to not overcome
the small bursts (as low as 2000 bytes) programmed on atbf qdisc, but
for high rates, we _definitely_ want to avoid segmentation as hell.

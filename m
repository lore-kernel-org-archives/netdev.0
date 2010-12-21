From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Tue, 21 Dec 2010 22:17:35 +0800
Message-ID: <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
 <20101220232020.GB2052@del.dom.local> <1292887689.2627.150.camel@edumazet-laptop>
 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Pawel Staszewski <pstaszewski@itcare.pl>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:59255 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985Ab0LUOXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 09:23:03 -0500
Received: by fxm18 with SMTP id 18so4363085fxm.2
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 06:23:02 -0800 (PST)
In-Reply-To: <1292939574.6535.27.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 9:52 PM, jamal <hadi@cyberus.ca> wrote:
>
> Use to be we couldnt get the ifb+mirred combo to work
> with TSO even without this change - i will have to dig old emails
> to remember details. So we are making progress;-> I did write a set
> of rules in: Documentation/networking/tc-actions-env-rules.txt
> Changli optimized rule #1. When i looked at his patch it seems
> to not harm that case. Sometimes dumb is a good principle ;->
>

In order to make my trick work. We need to assure dev_queue_xmit() and
dev_hard_start_xmit() accept shared skbs. As Eric pointed, pktgen also
need dev->netdev_ops->ndo_start_xmit() accept shared skbs. We need to
fix every ndo_start_xmit() one by one, then dev_hard_start_xmit(), and
when dev_queue_xmit() is also fixed, my trick can be added back.
:)

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)

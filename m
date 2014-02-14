From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/7] clear old options when old qdisc's replaced
Date: Fri, 14 Feb 2014 04:44:01 -0800
Message-ID: <1392381841.24974.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35542 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbaBNMoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 07:44:03 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so12226652pab.15
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 04:44:02 -0800 (PST)
In-Reply-To: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-14 at 16:36 +0800, Yang Yingliang wrote:
> I've added a netem qdisc with rate option, then I replace this qdisc
> without rate option but with latency option. The rate option is still
> there.
> 
> E.g.
>   # tc qdisc add dev eth4 handle 1: root netem rate 10mbit
>   # tc qdisc show
>     qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 10Mbit
> 
>   # tc qdisc replace dev eth4 handle 1: root netem latency 10ms
>   # tc qdisc show
>     qdisc netem 1: dev eth4 root refcnt 2 limit 1000 delay 10.0ms rate 10Mbit
> 
> The old options need be cleared after the qdisc is replaced.

Not at all. Test your changes with "tc qdisc change ... "

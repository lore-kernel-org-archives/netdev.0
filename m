From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v4] fq: allow options of fair queue set to ~0U
Date: Mon, 9 Jun 2014 12:43:33 -0700
Message-ID: <20140609124333.6890a846@nehalam.linuxnetplumber.net>
References: <1399868319-2184-1-git-send-email-yangyingliang@huawei.com>
	<1399874336.7973.17.camel@edumazet-glaptop2.roam.corp.google.com>
	<5370713F.7040701@huawei.com>
	<1399908225.7973.25.camel@edumazet-glaptop2.roam.corp.google.com>
	<53718221.6040909@huawei.com>
	<53719DA4.1010300@huawei.com>
	<20140528170957.19b50c12@nehalam.linuxnetplumber.net>
	<5386B1D2.3030804@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:42922 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020AbaFITrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 15:47:55 -0400
Received: by mail-pb0-f42.google.com with SMTP id md12so5350137pbc.29
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 12:47:54 -0700 (PDT)
In-Reply-To: <5386B1D2.3030804@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 May 2014 12:04:34 +0800
Yang Yingliang <yangyingliang@huawei.com> wrote:

> From: Yang Yingliang <yangyingliang@huawei.com>
> 
> Some options of fair queue cannot be (~0U). It leads to maxrate
> cannot be reset to unlimited because it cannot be (~0U). Allow
> the options being ~0U.
> 
> Tested by the following command:
>  # tc qdisc add dev eth4 root handle 1: fq limit 2000 flow_limit 200 maxrate 100mbit quantum 2000 initial_quantum 1600
>  # tc -s -d qdisc show
> qdisc fq 1: dev eth4 root refcnt 2 limit 2000p flow_limit 200p buckets 1024 quantum 2000 initial_quantum 1600 maxrate 100Mbit 
>  Sent 1492 bytes 10 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
>   1 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> 
>  # tc qdisc change dev eth4 root handle 1: fq limit 4294967295 flow_limit 4294967295 maxrate 34359738360 quantum 4294967295 initial_quantum 4294967295
>  # tc -s -d qdisc show
> qdisc fq 1: dev eth4 root refcnt 2 limit 4294967295p flow_limit 4294967295p buckets 1024 quantum 4294967295 initial_quantum 4294967295 
>  Sent 38372 bytes 216 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
>   2 flows (1 inactive, 0 throttled)
>   0 gc, 2 highprio, 7 throttled
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> 

Applied

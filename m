From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: pkt_sched: PIE AQM scheme
Date: Thu, 31 Oct 2013 09:52:14 -0700
Message-ID: <1383238334.4857.81.camel@edumazet-glaptop.roam.corp.google.com>
References: <1383167922-22495-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	Mythili Prabhu <mysuryan@cisco.com>,
	Dave Taht <dave.taht@bufferbloat.net>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:45233 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836Ab3JaQwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 12:52:16 -0400
Received: by mail-pd0-f169.google.com with SMTP id q10so2675935pdj.28
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 09:52:15 -0700 (PDT)
In-Reply-To: <1383167922-22495-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 14:18 -0700, Vijay Subramanian wrote:

> +static void pie_destroy(struct Qdisc *sch)
> +{
> +	struct pie_sched_data *q = qdisc_priv(sch);
> +	del_timer_sync(&q->adapt_timer);
> +}

This doesn't look safe to me.

timer can rearm itself.

Take a look at commit 980c478ddbb720948967b028ddbb4179a025bc2c

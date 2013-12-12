From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net-qdisc-hhf: Heavy-Hitter Filter (HHF) qdisc
Date: Wed, 11 Dec 2013 19:51:14 -0800
Message-ID: <1386820274.19078.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386746796-490-1-git-send-email-vtlam@google.com>
	 <1386814204-16000-1-git-send-email-vtlam@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Terry Lam <vtlam@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:56460 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab3LLDvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 22:51:16 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so10683703pdj.26
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 19:51:16 -0800 (PST)
In-Reply-To: <1386814204-16000-1-git-send-email-vtlam@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-11 at 18:10 -0800, Terry Lam wrote:

> +static u32 hhf_time_stamp(void)
> +{
> +	return jiffies;
> +}


This is a 32 bit value (For a good reason)

> +{
> +	struct hh_flow_state *flow, *next;
> +	unsigned long now = hhf_time_stamp();

stored in a 'unsigned long'

> +
> +	if (list_empty(head))
> +		return NULL;
> +
> +	list_for_each_entry_safe(flow, next, head, flowchain) {
> +		unsigned long prev = flow->hit_timestamp + q->hhf_evict_timeout;


32bit + ...

> +
> +		if (time_before(prev, now)) {

This wont work on 64 bit arches : Wrapping wont be detected anymore.

We keep 32bit variables to lower memory usage,
this is why we have special macros in include/net/codel.h

Please make sure you test your v3 patch, there is no hurry ;)

Thanks !

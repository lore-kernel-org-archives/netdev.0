From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NET_SCHED] sch_prio.c: remove duplicate call of
 tc_classify()
Date: Fri, 31 Aug 2007 08:04:31 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708310803260.13296@x2>
References: <20070830072817.GA9617@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Lucas Nussbaum <lucas.nussbaum@imag.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from port-195-158-167-14.dynamic.qsc.de ([195.158.167.14]:36100 "EHLO
	x2.localnet" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751766AbXIAINb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Sep 2007 04:13:31 -0400
In-Reply-To: <20070830072817.GA9617@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Aug 2007, Lucas Nussbaum wrote:

> When CONFIG_NET_CLS_ACT is enabled, tc_classify() is called twice in
> prio_classify(). This causes "interesting" behaviour: with the setup
> below, packets are duplicated, sent twice to ifb0, and then loop in and
> out of ifb0.
>
> The patch uses the previously calculated return value in the switch,
> which is probably what Patrick had in mind in commit
> bdba91ec70fb5ccbdeb1c7068319adc6ea9e1a7d -- maybe Patrick can
> double-check this?

> 		err = tc_classify(skb, q->filter_list, &res);
> #ifdef CONFIG_NET_CLS_ACT
> -		switch (tc_classify(skb, q->filter_list, &res)) {
> +		switch (err) {


Indeed, thats what I intended to do, thanks Lucas.


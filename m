From: Michal Soltys <nozo@ziu.info>
Subject: Re: Question about HFSC atm+man patches
Date: Fri, 28 Nov 2008 00:17:47 +0100
Message-ID: <492F2A9B.2050903@ziu.info>
References: <49292F54.4020803@ziu.info> <4929632F.3050200@trash.net> <492AB29A.3010601@ziu.info> <492AB60A.9050606@trash.net> <492DD399.4040801@ziu.info> <492E7B0B.8000601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3421 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752527AbYK0XtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 18:49:11 -0500
In-Reply-To: <492E7B0B.8000601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> 
> Using different size tables for inner qdiscs is supposed to work. 
> What is the "wrong size"? ->peek() should return a packet with the 
> size the same as ->dequeue() would, which I think it does.
> 

That's not what I meant.

((struct qdisc_skb_cb*)skb->cb)->pkt_len

This is the value returned by qdisc_pkt_len() (now used whenever length 
is required, instead of skb->len), and it's recalculated during 
qdisc_calculate_pkt_len() called from qdisc_enqueue() - if a qdisc has 
stab. So the inner(most) qdisc with a size table, will be the last one 
setting that field.

Now, if an outer qdisc, e.g. HFSC, does peek() or dequeue() later, 
qdisc_pkt_len() will return overridden value.

If no qdiscs in "chain" have stab, then the field will be equal to 
skb->len - which is set in qdisc_enqueue_root() (otherwise uninitialzed 
value would be used later).

Am I seeing this right ?


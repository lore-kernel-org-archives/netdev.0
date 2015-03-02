From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in
 sch_sfq
Date: Sun, 01 Mar 2015 16:58:52 -0800
Message-ID: <1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	 <1425247789-21211-7-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, fw@strlen.de
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:32983 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbbCBA6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 19:58:55 -0500
Received: by iecar1 with SMTP id ar1so44060330iec.0
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 16:58:54 -0800 (PST)
In-Reply-To: <1425247789-21211-7-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-03-01 at 14:09 -0800, Tom Herbert wrote:
> Call qdisc_skb_get_hash instead of doing skb_flow_dissect and then
> jhash by hand.

This defeats one of the perturbation goal :

If two flows hashes into same hash, then skb_get_hash_perturb(skb,
q->perturbation) will also give same hash forever and map to same hash
bucket.

Ideally, we could add a 'u32 perturbation' salt to
__skb_get_hash()/__flow_hash_from_keys()/__flow_hash_3words instead of
using a net_get_random_once(&hashrnd, sizeof(hashrnd)); 

but I guess all these functions are becoming very fat.

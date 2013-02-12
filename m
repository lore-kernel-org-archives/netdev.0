From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v5 10/11] tbf: take into account gso skbs
Date: Tue, 12 Feb 2013 09:54:25 -0800
Message-ID: <1360691665.6884.13.camel@edumazet-glaptop>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	 <1360663929-1023-11-git-send-email-jiri@resnulli.us>
	 <1360687182.6884.5.camel@edumazet-glaptop>
	 <20130212173127.GC18057@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:45921 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933559Ab3BLRy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 12:54:28 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so209145pad.37
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 09:54:27 -0800 (PST)
In-Reply-To: <20130212173127.GC18057@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 18:31 +0100, Jiri Pirko wrote:
> Tue, Feb 12, 2013 at 05:39:42PM CET, eric.dumazet@gmail.com wrote:

> >Ideally we could re-segment the skb if psched_l2t_ns(&q->peak, len) is
> >bigger than q->mtu
> 
> Okay - that sounds reasonable. Can you give me some hint how would you
> imagine to do this?
> 

This should be a generic helper, and we could use it in sch_codel /
sch_fq_codel / netem as well.

The trick in a qdisc is that we have to call qdisc_tree_decrease_qlen()
to alert parents that packet count changed.

If a GSO packet with 10 segments is segmented, we have to
qdisc_tree_decrease_qlen(sch, 1 - 10);

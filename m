From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: PROBLEM: a trivial bug in __copy_skb_header() ?
Date: Fri, 20 Feb 2009 09:59:42 -0300
Message-ID: <20090220125942.GA16897@ghostprotocols.net>
References: <85a560bb0902200045t1412c662k9b8ec337020e154f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chu XJ <zhuxjc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38248 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754529AbZBTM7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2009 07:59:46 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n1KCxk7R007429
	for <netdev@vger.kernel.org>; Fri, 20 Feb 2009 07:59:46 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n1KCxkPO006313
	for <netdev@vger.kernel.org>; Fri, 20 Feb 2009 07:59:46 -0500
Received: from doppio.ghostprotocols.net (vpn-13-32.rdu.redhat.com [10.11.13.32])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n1KCxiT2007358
	for <netdev@vger.kernel.org>; Fri, 20 Feb 2009 07:59:45 -0500
Content-Disposition: inline
In-Reply-To: <85a560bb0902200045t1412c662k9b8ec337020e154f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Feb 20, 2009 at 04:45:33PM +0800, Chu XJ escreveu:
> Hi, all
> 
>      I'm just a newbie of Linux kernel from China. I just wonder
> whether it should be "#ifdef CONFIG_XFRM" at the 504th line of
> net/core/skbuff.c in the V2.6.28 source tree and previous version.

Fairly recent code:

static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
{
        new->tstamp             = old->tstamp;
        new->dev                = old->dev;
        new->transport_header   = old->transport_header;
        new->network_header     = old->network_header;
        new->mac_header         = old->mac_header;
        new->dst                = dst_clone(old->dst);
#ifdef CONFIG_XFRM
        new->sp                 = secpath_get(old->sp);
#endif
        memcpy(new->cb, old->cb, sizeof(old->cb));
        new->csum_start         = old->csum_start;
        new->csum_offset        = old->csum_offset;
        new->local_df           = old->local_df;
        new->pkt_type           = old->pkt_type;
        new->ip_summed          = old->ip_summed;
        skb_copy_queue_mapping(new, old);
        new->priority           = old->priority;

Where do you think there is a problem?

- Arnaldo

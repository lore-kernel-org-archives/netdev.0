From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Fri, 08 Jun 2012 08:17:18 +0200
Message-ID: <1339136238.6001.28.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1206072201200.13686@pokey.mtv.corp.google.com>
	 <1339135057.6001.20.camel@edumazet-glaptop>
	 <20120607.230216.2014005732863772019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58586 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933517Ab2FHGRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 02:17:21 -0400
Received: by eaak11 with SMTP id k11so772774eaa.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 23:17:20 -0700 (PDT)
In-Reply-To: <20120607.230216.2014005732863772019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-07 at 23:02 -0700, David Miller wrote:

> Hmmm, isn't that what qdisc_skb_cb is for?  And even private data is
> explicitly allocated:
> 
> >  	unsigned char		data[24];
> 
> there. :-)
> 

By the way, I notice data[] is not aligned on a long on 64bit arches.

This might break net/sched/sch_netem.c on some arches, since
time_to_send is a u64.

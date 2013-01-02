From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inaccurate packet scheduling
Date: Wed, 02 Jan 2013 08:34:42 -0800
Message-ID: <1357144482.21409.16876.camel@edumazet-glaptop>
References: <e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
	 <1355849503.9380.37.camel@edumazet-glaptop>
	 <20130102152601.GB1532@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:59598 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964Ab3ABQeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 11:34:46 -0500
Received: by mail-da0-f50.google.com with SMTP id h15so6553641dan.9
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2013 08:34:45 -0800 (PST)
In-Reply-To: <20130102152601.GB1532@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-02 at 16:26 +0100, Jiri Pirko wrote:
> Tue, Dec 18, 2012 at 05:51:43PM CET, erdnetdev@gmail.com wrote:
> >On Tue, 2012-12-18 at 08:26 -0800, Stephen Hemminger wrote:
> >
> >> Check kernel log for messages about clock. It could be that on the
> >> machines with issues TSC is not usable for kernel clock.
> >> Also turn off TSO since it screws up any form of rate control.
> >
> >Yes, but we should fix it eventually. I'll take a look.
> 
> Hi Eric, did you have a chance to look at this? Or should I give it a try?

I took a look, and TBF does :

if (qdisc_pkt_len(skb) > q->max_size)
    return qdisc_reshape_fail(skb, sch);

We have several choices :

1) Add a one time warning

2) cap dev->gso_max_size at Qdisc setup time

3) Re-segment the packet instead of dropping it (if GSO packet), and
call the expensive qdisc_tree_decrease_qlen() function.

4) remove max_size limitation 

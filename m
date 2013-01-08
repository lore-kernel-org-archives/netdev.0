From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: inaccurate packet scheduling
Date: Tue, 8 Jan 2013 14:30:38 +0100
Message-ID: <20130108133038.GB1621@minipsycho.orion>
References: <e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
 <1355849503.9380.37.camel@edumazet-glaptop>
 <20130102152601.GB1532@minipsycho.orion>
 <1357144482.21409.16876.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:46588 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756257Ab3AHNam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 08:30:42 -0500
Received: by mail-we0-f169.google.com with SMTP id t49so346008wey.14
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 05:30:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1357144482.21409.16876.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 02, 2013 at 05:34:42PM CET, eric.dumazet@gmail.com wrote:
>On Wed, 2013-01-02 at 16:26 +0100, Jiri Pirko wrote:
>> Tue, Dec 18, 2012 at 05:51:43PM CET, erdnetdev@gmail.com wrote:
>> >On Tue, 2012-12-18 at 08:26 -0800, Stephen Hemminger wrote:
>> >
>> >> Check kernel log for messages about clock. It could be that on the
>> >> machines with issues TSC is not usable for kernel clock.
>> >> Also turn off TSO since it screws up any form of rate control.
>> >
>> >Yes, but we should fix it eventually. I'll take a look.
>> 
>> Hi Eric, did you have a chance to look at this? Or should I give it a try?
>
>I took a look, and TBF does :
>
>if (qdisc_pkt_len(skb) > q->max_size)
>    return qdisc_reshape_fail(skb, sch);
>
>We have several choices :
>
>1) Add a one time warning
>
>2) cap dev->gso_max_size at Qdisc setup time
>
>3) Re-segment the packet instead of dropping it (if GSO packet), and
>call the expensive qdisc_tree_decrease_qlen() function.
>
>4) remove max_size limitation 
>

To my untrained eye, 2) or 4) look like a way to go. Not sure though.

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Thu, 28 May 2015 09:26:46 -0700
Message-ID: <1432830406.7456.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com>
	 <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
	 <1432826085.7456.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <746223891.124020.1432827038389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
	 <5567382E.4010706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38552 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbbE1Q0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 12:26:48 -0400
Received: by igbjd9 with SMTP id jd9so28328428igb.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 09:26:48 -0700 (PDT)
In-Reply-To: <5567382E.4010706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Thu, 2015-05-28 at 08:45 -0700, John Fastabend wrote:
> If your experimenting one thing you could do is create many
> ifb devices and load balance across them from tc. I'm not
> sure if this would be practical in your setup or not but might
> be worth trying.
> 
> One thing I've been debating adding is the ability to match
> on current cpu_id in tc which would allow you to load balance by
> cpu. I could send you a patch if you wanted to test it. I would
> expect this to help somewhat with 'single queue' issue but sorry
> haven't had time yet to test it out myself.

It seems John uses a single 1Gbps flow, so only one cpu would receive
NIC interrupts.

The only way he could get better results would be to schedule IFB work
on another core.

(Assuming one cpu is 100% busy servicing NIC + IFB, but I really doubt
it...)

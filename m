From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: fq: clear time_next_packet for reused flows
Date: Sun, 27 Oct 2013 16:35:45 -0700
Message-ID: <1382916945.4045.22.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382612508.7572.53.camel@edumazet-glaptop.roam.corp.google.com>
	 <CAGK4HS945jCtfOoa_ENhTwZQvnSRJpHdWVDyhF+wjE56bjT8Pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:56105 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab3J0Xfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 19:35:47 -0400
Received: by mail-pd0-f171.google.com with SMTP id w10so4432689pde.16
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 16:35:46 -0700 (PDT)
In-Reply-To: <CAGK4HS945jCtfOoa_ENhTwZQvnSRJpHdWVDyhF+wjE56bjT8Pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-10-27 at 15:06 -0700, Vijay Subramanian wrote:

> Eric,
> By the way,  it looks like fq_flow_set_throttled() uses
> f->time_next_packet in an incorrect way.
> It is used as key to insert the flow into the delayed rb-tree but does
> not seem to check for duplicates.
> This could lead to rb tree corruption. I assume it is possible for
> different flows to have same f->time_next_packet.
> Do we at least we need a BUG_ON(f->time_next_packet ==
> aux->time_next_packet) here?
> 

What exact RB corruptions do you see ?

RB trees allow items with the same key.

HTB and netem use this property and I never saw any corruption,
but you could be right so please elaborate, thanks !

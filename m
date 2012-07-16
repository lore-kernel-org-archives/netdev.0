From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: timer expiry check at icmp.c in ipv6
Date: Mon, 16 Jul 2012 16:33:37 +0200
Message-ID: <1342449217.2830.3.camel@edumazet-glaptop>
References: <4A71D24947E78D43BC584A7CD4391A41017DBBAF@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42462 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab2GPOdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 10:33:41 -0400
Received: by eaak11 with SMTP id k11so1688264eaa.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 07:33:40 -0700 (PDT)
In-Reply-To: <4A71D24947E78D43BC584A7CD4391A41017DBBAF@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 13:44 +0000, BALAKUMARAN KANNAN wrote:
> Dear all,
> 
> In kernel-3.0.26 code net/ipv6/icmp.c, while sending ICMP reply where
> it checks for the timer expiry. It should check the value given by a
> router advertisement. I think the expiry value is stored in
> rt->rt6_expires in ndisc.c (line no: 1284). Then while sending an ICMP
> reply, it should check with the expiry timer right? Where that check
> is happening? Please somebody explain me.
> 
> Thank you.

Its probably done in net/ipv6/ip6_fib.c

fib6_gc_timer_cb() -> fib6_run_gc()

Every 30 seconds.

(you can change /proc/sys/net/ipv6/route/gc_interval )

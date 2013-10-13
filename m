From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6 path MTU discovery broken
Date: Sun, 13 Oct 2013 09:51:03 -0700
Message-ID: <1381683063.3392.46.camel@edumazet-glaptop.roam.corp.google.com>
References: <20130927201420.GB12043@sesse.net>
	 <20130928203318.GC23654@order.stressinduktion.org>
	 <20131006120612.GA27852@sesse.net>
	 <20131007015252.GE9295@order.stressinduktion.org>
	 <20131007030910.GG9295@order.stressinduktion.org>
	 <20131013104021.GB24967@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, edumazet@google.com, fan.du@windriver.com
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:56255 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873Ab3JMQvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 12:51:04 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so6380075pbb.27
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 09:51:02 -0700 (PDT)
In-Reply-To: <20131013104021.GB24967@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-10-13 at 12:40 +0200, Steinar H. Gunderson wrote:
> [resending with proper quoting and cc]
> 
> On Mon, Oct 07, 2013 at 05:09:10AM +0200, Hannes Frederic Sowa wrote:
> > Could you try to check (with e.g. nstat) if any of the following counters
> > change if the icmp messages hit the host?
> > 
> > TcpExtOutOfWindowIcmps
> > Icmp6InErrors
> > TcpExtTCPMinTTLDrop
> > TcpExtListenDrops
> 
> Hi,
> 
> I am now seeing the same problem against a 3.9.0 machine (that I've never had
> problems with before). I looked through the four nstat counters, and none of
> them are increasing. Here's /proc/net/ipv6_route from the server while it's
> going on; the client is 2001:67c:a4:1:71f9:c84b:8b2a:c65b (second line) and
> the server is 2001:67c:29f4::2007.

I am not sure, but the skb_is_gso() checks seem too lazy.

Why don't we check that gso_size+headers is below mtu, I dont know.

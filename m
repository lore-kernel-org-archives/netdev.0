From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path MTU discovery broken
Date: Sun, 13 Oct 2013 19:56:19 +0200
Message-ID: <20131013175619.GC14021@order.stressinduktion.org>
References: <20130927201420.GB12043@sesse.net> <20130928203318.GC23654@order.stressinduktion.org> <20131006120612.GA27852@sesse.net> <20131007015252.GE9295@order.stressinduktion.org> <20131007030910.GG9295@order.stressinduktion.org> <20131013104021.GB24967@sesse.net> <1381683063.3392.46.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	netdev@vger.kernel.org, edumazet@google.com, fan.du@windriver.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60045 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754917Ab3JMR4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 13:56:20 -0400
Content-Disposition: inline
In-Reply-To: <1381683063.3392.46.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 13, 2013 at 09:51:03AM -0700, Eric Dumazet wrote:
> On Sun, 2013-10-13 at 12:40 +0200, Steinar H. Gunderson wrote:
> > [resending with proper quoting and cc]
> > 
> > On Mon, Oct 07, 2013 at 05:09:10AM +0200, Hannes Frederic Sowa wrote:
> > > Could you try to check (with e.g. nstat) if any of the following counters
> > > change if the icmp messages hit the host?
> > > 
> > > TcpExtOutOfWindowIcmps
> > > Icmp6InErrors
> > > TcpExtTCPMinTTLDrop
> > > TcpExtListenDrops
> > 
> > Hi,
> > 
> > I am now seeing the same problem against a 3.9.0 machine (that I've never had
> > problems with before). I looked through the four nstat counters, and none of
> > them are increasing. Here's /proc/net/ipv6_route from the server while it's
> > going on; the client is 2001:67c:a4:1:71f9:c84b:8b2a:c65b (second line) and
> > the server is 2001:67c:29f4::2007.
> 
> I am not sure, but the skb_is_gso() checks seem too lazy.
> 
> Why don't we check that gso_size+headers is below mtu, I dont know.

Was this intended for the UFO gso thread? ;)

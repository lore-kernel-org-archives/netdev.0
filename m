From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6 routing table max_size badly dimensioned compared to IPv4
Date: Thu, 27 Feb 2014 13:02:00 -0800
Message-ID: <1393534920.26794.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140227192403.GA13472@xs.powerdns.com>
	 <1393531144.26794.24.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140227200814.GA27495@order.stressinduktion.org>
	 <1393532583.26794.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140227205010.GB27495@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bert hubert <bert.hubert@netherlabs.nl>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:48604 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbaB0VCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 16:02:04 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so2906988pdj.26
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 13:02:03 -0800 (PST)
In-Reply-To: <20140227205010.GB27495@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-27 at 21:50 +0100, Hannes Frederic Sowa wrote:

> We store those routes back into the routing table, so we must have a way to
> count them and trigger gc at some point.

Right, and current implementation will not scale.

If we need to perform 10000 inserts per second, and gc timeout is 60
seconds, tree contains 600.000 entries, gc takes forever...

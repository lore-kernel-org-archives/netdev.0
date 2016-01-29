From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 11:06:34 -0800 (PST)
Message-ID: <20160129.110634.1678121731419241040.davem@davemloft.net>
References: <20160129180651.GA17127@oracle.com>
	<1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555AbcA2TGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 14:06:35 -0500
In-Reply-To: <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jan 2016 10:33:48 -0800

> Why ipv6 stack itself does not trigger the issue ?
> 
> Maybe the driver itself does not properly align IP headers on sparc ?
> 
> Make sure NET_IP_ALIGN is 2 on your build.
> 
> Note that x86 does not care, but a driver should always align Ethernet
> header to NET_IP_ALIGN, so that IP headers are aligned to 4 bytes
> boundaries.

Eric, please reread the original posting, the driver is trying to do
exactly this.

This is the part in the driver where it is trying to figure out how
much to pull in order to align the packet before it gets sent into the
stack.

That's why only the flow dissector sees this problem.

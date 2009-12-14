From: David Miller <davem@davemloft.net>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 11:11:05 -0800 (PST)
Message-ID: <20091214.111105.224947761.davem@davemloft.net>
References: <20091213.234530.82029083.davem@davemloft.net>
	<4B267708.3010202@gmail.com>
	<1260817033.9141.8.camel@merlyn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59617
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932418AbZLNTLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 14:11:03 -0500
In-Reply-To: <1260817033.9141.8.camel@merlyn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Mon, 14 Dec 2009 18:57:13 +0000

> That test was changed to match a change in the return values of
> tcp_ack().  No logic change was intended.

As Eric pointed out, changing tcp_ack()'s behavior effects state
transitions out of SYN_ACK, so this commit is very likely the culprit.

I usually see 2 or 3 three of these bug triggers in the first ten
minutes after bootup and I haven't seen one yet in 20 minutes
with the commit reverted.

This change is definitely wrong.

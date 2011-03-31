From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] socket: increase default maximum listen queue
 length
Date: Wed, 30 Mar 2011 22:52:54 -0700 (PDT)
Message-ID: <20110330.225254.104054904.davem@davemloft.net>
References: <1301077899-16482-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39662
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755327Ab1CaFxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 01:53:31 -0400
In-Reply-To: <1301077899-16482-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Fri, 25 Mar 2011 19:31:38 +0100

> sysctl_max_syn_backlog on the other hand provides similar functionality:
> provides a system wide upper limit of request sockets per listen socket.
> But sysctl_max_syn_backlog provides a more accurate value by considerate
> the actual memory situation of the system. 256 by default, 128 for
> systems with low memory and up to 1024 for larger systems.

sysctl_max_syn_backlog is not "256 by default", the calculation is:

	cnt = tcp_hashinfo.ehash_mask + 1;
 ...
	sysctl_max_syn_backlog = max(128, cnt / 256);

And I think we should leave the SOMAXCONN define alone (it's a
historic relic for userspace, and any sane server passes something
like ~0 into listen()).

And calculate the somaxconn sysctl at run time using a similar
formula to that used by sysctl_max_syn_backlog.

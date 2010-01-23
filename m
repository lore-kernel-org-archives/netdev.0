From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: Fix a UDP socket reference count bug in the
 pppol2tp driver
Date: Sat, 23 Jan 2010 01:55:11 -0800 (PST)
Message-ID: <20100123.015511.83860202.davem@davemloft.net>
References: <20100121161009.5223.34288.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752506Ab0AWJzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:55:00 -0500
In-Reply-To: <20100121161009.5223.34288.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Thu, 21 Jan 2010 16:10:09 +0000

> The bug can cause a kernel stack trace when a tunnel socket is closed.
> 
> WARNING: at include/net/sock.h:435 udp_lib_unhash+0x117/0x120()
> Pid: 1086, comm: openl2tpd Not tainted 2.6.33-rc1 #8
> Call Trace:

This fix doesn't look right at all.

You grab one reference in connect() and then drop a reference
every single recvmsg() call.

recvmsg() calls to connect() would be many to one, so I can't
see how this reference counting scheme could possibly work.

Why don't you describe the exact sequence of events that lead
to the trace, so we can figure out how to correct this
properly?

Thanks.

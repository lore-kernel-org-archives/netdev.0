From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] proc connector: add event for process becoming
 session leader
Date: Wed, 12 Aug 2009 17:32:03 -0700 (PDT)
Message-ID: <20090812.173203.35197832.davem@davemloft.net>
References: <200908062305.n76N5lZj005259@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scott@ubuntu.com, johnpol@2ka.mipt.ru,
	matthltc@us.ibm.com, oleg@tv-sign.ru
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49184
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750866AbZHMAbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 20:31:53 -0400
In-Reply-To: <200908062305.n76N5lZj005259@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 06 Aug 2009 16:05:47 -0700

> From: Scott James Remnant <scott@ubuntu.com>
> 
> The act of a process becoming a session leader is a useful signal to a
> supervising init daemon such as Upstart.
> 
> While a daemon will normally do this as part of the process of becoming a
> daemon, it is rare for its children to do so.  When the children do, it is
> nearly always a sign that the child should be considered detached from the
> parent and not supervised along with it.
> 
> The poster-child example is OpenSSH; the per-login children call setsid()
> so that they may control the pty connected to them.  If the primary daemon
> dies or is restarted, we do not want to consider the per-login children
> and want to respawn the primary daemon without killing the children.
> 
> This patch adds a new PROC_SID_EVENT and associated structure to the
> proc_event event_data union, it arranges for this to be emitted when the
> special PIDTYPE_SID pid is set.
> 
> [akpm@linux-foundation.org: coding-style fixes]
> Signed-off-by: Scott James Remnant <scott@ubuntu.com>
> Acked-by: Matt Helsley <matthltc@us.ibm.com>
> Cc: Oleg Nesterov <oleg@tv-sign.ru>
> Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: David S. Miller <davem@davemloft.net>

This is more process handling level stuff than actual networking
or connector bits, so it should probably be merged via akpm's
usual patch bombs or some other relevant tree.

Andrew, if you really want, I can take this into net-next-2.6


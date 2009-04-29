From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Wed, 29 Apr 2009 08:53:52 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0904290850210.25124@makko.or.mcafeemobile.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com>
 <20090429091637.GA29874@elte.hu> <49F81FB9.50504@cosmosbay.com> <20090429102734.GC2373@elte.hu> <49F84833.5000908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:47457 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757426AbZD2P6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 11:58:03 -0400
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2E4309> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Wed, 29 Apr 2009 11:57:12 -0400
In-Reply-To: <49F84833.5000908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Apr 2009, Eric Dumazet wrote:

> [PATCH] poll: Avoid extra wakeups in select/poll
> 
> After introduction of keyed wakeups Davide Libenzi did on epoll, we
> are able to avoid spurious wakeups in poll()/select() code too.
> 
> For example, typical use of poll()/select() is to wait for incoming
> network frames on many sockets. But TX completion for UDP/TCP 
> frames call sock_wfree() which in turn schedules thread.
> 
> When scheduled, thread does a full scan of all polled fds and
> can sleep again, because nothing is really available. If number
> of fds is large, this cause significant load.
> 
> This patch makes select()/poll() aware of keyed wakeups and
> useless wakeups are avoided. This reduces number of context
> switches by about 50% on some setups, and work performed
> by sofirq handlers.

Looks fine to me Eric ...

Acked-by: Davide Libenzi <davidel@xmailserver.org>


- Davide



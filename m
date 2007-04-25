From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: Getting the new RxRPC patches upstream
Date: Wed, 25 Apr 2007 14:41:45 +0400
Message-ID: <20070425104145.GA83@tv-sign.ru>
References: <2969.1176992303@redhat.com> <1101.1177056127@redhat.com> <4713.1177065706@redhat.com> <20070420113805.c4877dc8.akpm@linux-foundation.org> <1355.1177317176@redhat.com> <9767.1177421824@redhat.com> <15160.1177429867@redhat.com> <16575.1177433907@redhat.com> <17966.1177438970@redhat.com> <5461.1177488612@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	containers@lists.osdl.org, hch@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.screens.ru ([213.234.233.54]:46493 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992572AbXDYKm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 06:42:26 -0400
Content-Disposition: inline
In-Reply-To: <5461.1177488612@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/25, David Howells wrote:
>
> Oleg Nesterov <oleg@tv-sign.ru> wrote:
> 
> > Yes sure. Note that this is documented:
> > 
> > 	/*
> > 	 * Kill off a pending schedule_delayed_work().  Note that the work callback
> > 	 * function may still be running on return from cancel_delayed_work().  Run
> > 	 * flush_workqueue() or cancel_work_sync() to wait on it.
> > 	 */
> 
> No, it isn't documented.  It says that the *work* callback may be running, but
> does not mention the timer callback.  However, just looking at the
> cancellation function source made it clear that this would wait for the timer
> handler to return first.

Ah yes, it says nothing about what the returned value means...

> However, is it worth just making cancel_delayed_work() a void function and not
> returning anything?  I'm not sure the return value is very useful.

cancel_rearming_delayed_work() needs this, tty_io.c, probably somebody else.

Oleg.


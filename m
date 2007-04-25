From: David Howells <dhowells@redhat.com>
Subject: Re: Getting the new RxRPC patches upstream
Date: Wed, 25 Apr 2007 09:10:12 +0100
Message-ID: <5461.1177488612@redhat.com>
References: <20070424193404.GA5042@tv-sign.ru>  <29341.1176975158@redhat.com> <2969.1176992303@redhat.com> <1101.1177056127@redhat.com> <4713.1177065706@redhat.com> <20070420113805.c4877dc8.akpm@linux-foundation.org> <1355.1177317176@redhat.com> <9767.1177421824@redhat.com> <15160.1177429867@redhat.com> <16575.1177433907@redhat.com> <17966.1177438970@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	containers@lists.osdl.org, hch@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161706AbXDYIKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 04:10:40 -0400
In-Reply-To: <20070424193404.GA5042@tv-sign.ru> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oleg Nesterov <oleg@tv-sign.ru> wrote:

> Yes sure. Note that this is documented:
> 
> 	/*
> 	 * Kill off a pending schedule_delayed_work().  Note that the work callback
> 	 * function may still be running on return from cancel_delayed_work().  Run
> 	 * flush_workqueue() or cancel_work_sync() to wait on it.
> 	 */

No, it isn't documented.  It says that the *work* callback may be running, but
does not mention the timer callback.  However, just looking at the
cancellation function source made it clear that this would wait for the timer
handler to return first.


However, is it worth just making cancel_delayed_work() a void function and not
returning anything?  I'm not sure the return value is very useful.

David

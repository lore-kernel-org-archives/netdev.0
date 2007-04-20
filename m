From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: Getting the new RxRPC patches upstream
Date: Sat, 21 Apr 2007 01:28:35 +0400
Message-ID: <20070420212835.GA863@tv-sign.ru>
References: <20070420.015838.83621529.davem@davemloft.net> <29341.1176975158@redhat.com> <2969.1176992303@redhat.com> <1101.1177056127@redhat.com> <4713.1177065706@redhat.com> <20070420113805.c4877dc8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>,
	David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	containers@lists.osdl.org, hch@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1767268AbXDTV3J@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070420113805.c4877dc8.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/20, Andrew Morton wrote:
>
> On Fri, 20 Apr 2007 11:41:46 +0100
> David Howells <dhowells@redhat.com> wrote:
> 
> > There are only two non-net patches that AF_RXRPC depends on:
> > 
> >  (1) The key facility changes.  That's all my code anyway, and shouldn't be a
> >      problem to merge unless someone else has put some changes in there that I
> >      don't know about.
> > 
> >  (2) try_to_cancel_delayed_work().  I suppose I could use
> >      cancel_delayed_work() instead, but that's less efficient as it waits for
> >      the timer completion function to finish.
> 
> There are significant workqueue changes in -mm and I plan to send them
> in for 2.6.22.  I doubt if there's anything in there which directly
> affects cancel_delayed_work(), but making changes of this nature against
> 2.6.21 might lead to grief.

I think it is better to use cancel_delayed_work(), but change it to use
del_timer(). I belive cancel_delayed_work() doesn't need del_timer_sync().

We only care when del_timer() returns true. In that case, if the timer
function still runs (possible for single-threaded wqs), it has already
passed __queue_work().

Oleg.

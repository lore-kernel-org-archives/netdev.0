From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take21 1/4] kevent: Core files.
Date: Sat, 28 Oct 2006 17:28:16 +0400
Message-ID: <20061028132816.GA25452@2ka.mipt.ru>
References: <11619654011980@2ka.mipt.ru> <454330BC.9000108@cosmosbay.com> <20061028105340.GC15038@2ka.mipt.ru> <45434ECF.4090209@cosmosbay.com> <20061028130350.GA18737@2ka.mipt.ru> <454359DC.4020905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752330AbWJ1N2w@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <454359DC.4020905@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 28, 2006 at 03:23:40PM +0200, Eric Dumazet (dada1@cosmosbay.com) wrote:
> >diff --git a/kernel/kevent/kevent_user.c b/kernel/kevent/kevent_user.c
> >index 711a8a8..ecee668 100644
> >--- a/kernel/kevent/kevent_user.c
> >+++ b/kernel/kevent/kevent_user.c
> >@@ -235,6 +235,36 @@ static void kevent_free_rcu(struct rcu_h
> > }
> > 
> > /*
> >+ * Must be called under u->ready_lock.
> >+ * This function removes kevent from ready queue and 
> >+ * tries to add new kevent into ring buffer.
> >+ */
> >+static void kevent_remove_ready(struct kevent *k)
> >+{
> >+	struct kevent_user *u = k->user;
> >+
> >+	list_del(&k->ready_entry);
> 
> Arg... no
> 
> You cannot call list_del() , then check overflow_kevent.
> 
> I you call list_del on what happens to be the kevent pointed by 
> overflow_kevent, you loose...

This function is always called from appropriate context, where it is
guaranteed that it is safe to call list_del:
1. when kevent is removed. It is called after check, that given kevent 
is in the ready queue.
2. when dequeued from ready queue, which means that it can be removed
from that queue.

-- 
	Evgeniy Polyakov

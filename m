From: David Howells <dhowells@redhat.com>
Subject: Re: [patch] RxRPC: use copy_to_user() instead of memcpy()
Date: Tue, 19 Mar 2013 13:59:30 +0000
Message-ID: <30707.1363701570@warthog.procyon.org.uk>
References: <20130319.094240.1315516663563952557.davem@davemloft.net> <20130318105503.GA17102@longonot.mountain>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>, dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754696Ab3CSN7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 09:59:36 -0400
In-Reply-To: <20130319.094240.1315516663563952557.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

> >  		/* copy the peer address and timestamp */
> >  		if (!continue_call) {
> > -			if (msg->msg_name && msg->msg_namelen > 0)
> > -				memcpy(msg->msg_name,
> > -				       &call->conn->trans->peer->srx,
> > -				       sizeof(call->conn->trans->peer->srx));
> 
> I bet the size is too large for a sockaddr_storage, and therefore we
> spam the kernel stack.  So I can only guess that changing this to a
> copy_to_user() fixes the hang because it simply faults on the kernel
> destination address.

Maybe, though I don't see how that would just fix the hang rather than
oopsing.  If Dan can printk the following:

	msg->msg_namelen
	sizeof(call->conn->trans->peer->srx)

before doing the memcpy, that could be handy.

David

From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NETLABEL: Fix an RCU warning
Date: Thu, 25 Mar 2010 11:37:24 +0000
Message-ID: <6522.1269517044@redhat.com>
References: <1269516484.3626.21.camel@edumazet-laptop> <20100325110621.5348.32020.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, paul.moore@hp.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65117 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753797Ab0CYLiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Mar 2010 07:38:05 -0400
In-Reply-To: <1269516484.3626.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Sorry this is not the right fix.
> 
> Fix is to change the dereference check to take into account the lock
> owned here.

Then the comments on netlbl_unlhsh_hash(), netlbl_unlhsh_search_iface(),
netlbl_unlhsh_search_iface_def() and netlbl_unlhsh_add_iface() are all wrong,
for all of them say:

	* The caller is responsible for calling the rcu_read_[un]lock()
	* functions.

Furthermore, netlabel_unlhsh_add() and netlabel_unlhsh_remove() _do_ wrap the
calls to those functions in rcu_read_lock'd sections.

David

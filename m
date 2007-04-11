From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 8/8] AFS: Add security support
Date: Wed, 11 Apr 2007 21:10:32 +0100
Message-ID: <18379.1176322232@redhat.com>
References: <20070411193844.GC3704@fieldses.org>  <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com> <20070411191037.15499.67852.stgit@warthog.cambridge.redhat.com>
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030433AbXDKUKs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 16:10:48 -0400
In-Reply-To: <20070411193844.GC3704@fieldses.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J. Bruce Fields <bfields@fieldses.org> wrote:

> Just curious--when is the actual crypto done?  There doesn't seem to be
> any in this patch.

See AF_RXRPC patch:

	http://people.redhat.com/~dhowells/rxrpc/04-af_rxrpc.diff

You turn on CONFIG_RXKAD and load the rxkad module thus built (assuming you
haven't built it in) after loading the af_rxrpc module.  I probably should've
mentioned that in the cover.

So anyone using sockets of family AF_RXRPC can use it.  See these test
programs:

 (1) The klog test program fetches a ticket from the kaserver and adds it as a
     key of type rxrpc:

	http://people.redhat.com/~dhowells/rxrpc/klog.c

 (2) The listen test program which listens for potentially secured incoming
     calls:

	http://people.redhat.com/~dhowells/rxrpc/listen.c

 (3) The rxrpc test program which can make secure calls:

	http://people.redhat.com/~dhowells/rxrpc/rxrpc.c

David

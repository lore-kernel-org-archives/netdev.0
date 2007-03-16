From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 4/5] AF_RXRPC: Key facility changes for AF_RXRPC [try #2]
Date: Fri, 16 Mar 2007 14:15:46 +0000
Message-ID: <25410.1174054546@redhat.com>
References: <20070316133824.GC2173@infradead.org>  <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <20070316125031.3740.36610.stgit@warthog.cambridge.redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, arjan@infradead.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52719 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704AbXCPOQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 10:16:01 -0400
In-Reply-To: <20070316133824.GC2173@infradead.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig <hch@infradead.org> wrote:

> You wrote the code so there must be some reason for this, but these
> changes look rather odd to me :)

The union is for use by the type in any way it sees fit, but it may not want to
use it as a list_head.  So all I've done is to make it available as a pair of
arbitrary pointers or a pair of arbitrary numbers.

Maybe a better way would be to have an overlay struct that's private to the
type, sort of how sk_buff::cb works.

> Having a type exported is really odd, how is this supposed to be a public API?

Keyrings are a special type.

It occurred to me whilst doing this that the best way to achieve what I wanted
was by dealing with rings of keys.  What I needed was for the server app to
give the kernel a key for each security type it wanted to support, which the
kernel would then have to retain.  It seems natural to use a keyring to do the
retension as that's its purpose.

Another way to look at it is that in the client I need just one key at once,
and I can get that from the process as it's setting up the connection.
However, in the server I need to have several keys, and I need them available
up front because the server app doesn't set up a connection, the kernel does,
and it needs the keys immediately.

I'll add a mention to Documentation/keys.txt to record this exportation.

David

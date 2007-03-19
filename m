From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #2]
Date: Mon, 19 Mar 2007 11:56:43 +0000
Message-ID: <2578.1174305403@redhat.com>
References: <20070318142315.6f881ec8@lxorguk.ukuu.org.uk>  <20070316153408.3a9a244a@lxorguk.ukuu.org.uk> <20070316151305.04cbc352@lxorguk.ukuu.org.uk> <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <25571.1174054993@redhat.com> <26525.1174058071@redhat.com> <20070316171141.7a4de504@lxorguk.ukuu.org.uk> <076F1B35-BE08-41B4-8294-581EDAFF4ACC@mac.com>
Cc: Kyle Moffett <mrmacman_g4@mac.com>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54195 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753797AbXCSL5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 07:57:15 -0400
In-Reply-To: <20070318142315.6f881ec8@lxorguk.ukuu.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > IMHO the problem with classifying RxRPC as a "reliable datagram"  
> > socket is that even an atomic unidirectional communication isn't a  
> > single datagram, it's at least 3; there is shared connection state  
> 
> Thats fine. Any *reliable* protocol sends more than one packet per
> message you send. RDM is for reliable messages

I'm not arguing with that.  Why I think RDM is the wrong thing to use is that
there seems to be a perception that RDM involves a unidirectional, single
message transmission.  You yourself defined RDM to be a datagram service.
RxRPC is not, in my opinion, a datagram service, and neither is it a stream
service.

Interestingly, searching for SOCK_RDM definitions with google shows there's
some disagreement as to what it represents.  Some seem to thing it's connection
oriented and some that it's connectionless, and some seem to think it's
ordered, and some not.

> > independent and possibly simultaneous RxRPC calls.  From the digging  
> > around that I did in the kernel socket code a while ago I don't see a  
> > cleaner way of implementing it than a new SOCK_RXRPC.

Well, I suggest SOCK_RPC, not SOCK_RXRPC.  There's no particular reason such a
flow type has to be limited to RxRPC.

> I disagree entirely.

That's your prerogative.

> I've still seen no evidence you need a new type for this.

Conversely, you haven't shown that any of the existing types are suitable
either.

Strictly, the "type" parameter for RxRPC family sockets is completely
irrelevant as only one flow type is supported anyway; but still, I'd like to
get it right.

Looking at the socket(2) manpage, I see the definition of the SOCK_RDM to be:

	Provides a reliable datagram layer that does not guarantee ordering.

I'd say that that precludes applicability on two points: firstly, RxRPC is not
a datagram layer by the definition I provided in a previous email; and
secondly, RxRPC *does* provide some ordering guarantees.

> What does AIX do out of interest ?

I've no way to find out what AIX does, but I suspect it simply doesn't.

The way OpenAFS does things is that it has an RxRPC library that can be
compiled either in userspace or in kernel space.  Userspace AFS utilities use
the userspace-compiled library, which simply uses a UDP socket as its kernel
interface; the kernel code uses the same library, but compiled for existence
within the kernel.

David

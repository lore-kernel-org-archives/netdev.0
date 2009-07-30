From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Thu, 30 Jul 2009 08:49:57 -0700
Message-ID: <878wi6yxui.fsf@caffeine.danplanet.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
	<1248295301-30930-6-git-send-email-danms@us.ibm.com>
	<4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>
	<4A6F6B19.9010508@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: Oren Laadan <orenl@librato.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:59623 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751459AbZG3PuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 11:50:11 -0400
In-Reply-To: <4A6F6B19.9010508@librato.com> (Oren Laadan's message of "Tue\, 28 Jul 2009 17\:18\:17 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OL> Hmm.. then what happens when you have a circular dependency ?  For
OL> example, three dgram sockets, A, B and C where: A->B, B->C and
OL> C->A ('->' means connected).

So, I've been cooking up changes to the patch and a test for this
case.  However, it seems like it's not valid, unless I'm missing
something.  The man page for connect() says:

  If the socket sockfd is of type SOCK_DGRAM then serv_addr is the
  address to which datagrams are sent by default, and the only address
  from which datagrams are received.

So, even though you can connect() a DGRAM socket and then sendto()
datagrams to a different location, it doesn't appear that the
relationship between A and B is really valid, at least the connection
between A and B is not functional.  In fact, in my testing, if you try
to connect() C back to A, you get "Operation not permitted" because A
is already connected elsewhere.

Thoughts?

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

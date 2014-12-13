From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [WTF?] random test in netlink_sendmsg()
Date: Sat, 13 Dec 2014 01:54:15 +0000
Message-ID: <20141213015415.GG22149@ZenIV.linux.org.uk>
References: <20141128062315.GC29748@ZenIV.linux.org.uk>
 <20141212.153433.1675057029307550538.davem@davemloft.net>
 <20141212213242.GE22149@ZenIV.linux.org.uk>
 <20141212.200758.944592759380344519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53538 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933159AbaLMByR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 20:54:17 -0500
Content-Disposition: inline
In-Reply-To: <20141212.200758.944592759380344519.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 08:07:58PM -0500, David Miller wrote:
> From: Al Viro <viro@ZenIV.linux.org.uk>
> Date: Fri, 12 Dec 2014 21:32:43 +0000
> 
> > What do we want sendmsg(fd, &msg, 0) to do when fd is AF_NETLINK socket
> > that had setsockopt(fd, SOL_NETLINK, NETLINK_TX_RING, ...) successfully done
> > to it and msg.msg_iovlen is 0?
> 
> We had a similar issue with msg_name/msg_namelen and we ended up saying
> that if msg_namelen is zero then we force msg_name to NULL.

Hmm...  The thing is, there might be legitimate users with empty payload,
making this call for the sake of SCM_CREDENTIALS.  IOW, what should happen
if we have
	msg_iovlen = 0
	msg_iov = <anything>
	msg_control = &cmsg
	msg_controllen = cmsg_len
Sure, both paths will pass creds, but what about the payload?  And the number
of datagram actually transmitted, for that matter?

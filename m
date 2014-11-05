From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Wed, 5 Nov 2014 03:55:36 +0000
Message-ID: <20141105035536.GO7996@ZenIV.linux.org.uk>
References: <20141104144258.GA14743@gondor.apana.org.au>
 <20141104151353.GG7996@ZenIV.linux.org.uk>
 <20141105022251.GA19136@gondor.apana.org.au>
 <20141104.222727.275422581392488793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141104.222727.275422581392488793.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 04, 2014 at 10:27:27PM -0500, David Miller wrote:

> Al, is this the helper you are talking about?

Mostly, except that I kept it 4-argument (and used skb_copy_datagram_msg()
for name).  Matter of taste - the ones you've missed because of that are

net/appletalk/ddp.c:1761:	err = skb_copy_datagram_iovec(skb, offset, msg->msg_iov, copied);
net/ipv4/tcp.c:1836:			err = skb_copy_datagram_iovec(skb, offset,
net/ipv4/udp.c:1284:		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
net/ipv6/udp.c:427:			err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
net/ipx/af_ipx.c:1808:	rc = skb_copy_datagram_iovec(skb, sizeof(struct ipxhdr), msg->msg_iov,
net/iucv/af_iucv.c:1358:	if (skb_copy_datagram_iovec(cskb, offset, msg->msg_iov, copied)) {
net/llc/af_llc.c:822:			int rc = skb_copy_datagram_iovec(skb, offset,
net/rxrpc/ar-recvmsg.c:183:		ret = skb_copy_datagram_iovec(skb, offset, msg->msg_iov, copy);
net/tipc/socket.c:1375:		res = skb_copy_datagram_iovec(buf, msg_hdr_sz(msg),
net/tipc/socket.c:1476:		res = skb_copy_datagram_iovec(buf, msg_hdr_sz(msg) + offset,
net/unix/af_unix.c:1828:	err = skb_copy_datagram_iovec(skb, skip, msg->msg_iov, size);
net/unix/af_unix.c:2033:		if (skb_copy_datagram_iovec(skb, UNIXCB(skb).consumed + skip,
net/vmw_vsock/vmci_transport.c:1776:	err = skb_copy_datagram_iovec(skb, sizeof(*dg), msg->msg_iov,

and back then I decided that 13 more converted instances might be worth keeping
it in 4-argument form...

What do you think of the trick with user_msghdr, BTW?

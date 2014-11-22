From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Sat, 22 Nov 2014 04:28:57 +0000
Message-ID: <20141122042856.GZ7996@ZenIV.linux.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <20141120.182339.972861702759954603.davem@davemloft.net>
 <20141121.122615.1091044030302005883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	nab@linux-iscsi.org, hch@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141121.122615.1091044030302005883.davem@davemloft.net>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	OK, here's the next bunch.  Sorry about the delay, iov_iter.c stuff
took most of the day (and it's not included in this pile).  Please, review.
Al Viro (17):
      new helper: skb_copy_and_csum_datagram_msg()
      new helper: memcpy_from_msg()
      switch ipxrtr_route_packet() from iovec to msghdr
      new helper: memcpy_to_msg()
      switch drivers/net/tun.c to ->read_iter()
      switch macvtap to ->read_iter()
      new helpers: skb_copy_datagram_from_iter() and zerocopy_sg_from_iter()
      {macvtap,tun}_get_user(): switch to iov_iter
      kill zerocopy_sg_from_iovec()
      switch AF_PACKET and AF_UNIX to skb_copy_datagram_from_iter()
      switch sctp_user_addto_chunk() and sctp_datamsg_from_user() to passing iov_iter
      tipc_sendmsg(): pass msghdr instead of its ->msg_iov
      tipc_msg_build(): pass msghdr instead of its ->msg_iov
      vmci_transport: switch ->enqeue_dgram, ->enqueue_stream and ->dequeue_stream to msghdr
      [atm] switch vcc_sendmsg() to copy_from_iter()
      rds: switch ->inc_copy_to_user() to passing iov_iter
      rds: switch rds_message_copy_from_user() to iov_iter

Patches themselves are in followups...

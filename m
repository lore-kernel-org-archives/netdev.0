From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports from the host TCP
 port space.
Date: Tue, 07 Aug 2007 10:06:29 -0500
Message-ID: <46B88A75.3040004@opengridcomputing.com>
References: <46B883B5.8040702@opengridcomputing.com> <20070807145441.GA24895@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]:35263 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751430AbXHGPGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 11:06:30 -0400
In-Reply-To: <20070807145441.GA24895@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Evgeniy Polyakov wrote:
> Hi Steve.
> 
> On Tue, Aug 07, 2007 at 09:37:41AM -0500, Steve Wise (swise@opengridcomputing.com) wrote:
>> +static int cma_get_tcp_port(struct rdma_id_private *id_priv)
>> +{
>> +	int ret;
>> +	struct socket *sock;
>> +
>> +	ret = sock_create_kern(AF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
>> +	if (ret)
>> +		return ret;
>> +	ret = sock->ops->bind(sock,
>> +			  (struct socketaddr 
>> *)&id_priv->id.route.addr.src_addr,
>> +			  ip_addr_size(&id_priv->id.route.addr.src_addr));
> 
> If get away from talks about broken offloading, this one will result in
> the case, when usual network dataflow can enter private rdma land, i.e.
> after bind succeeded this socket is accessible via any other network
> device. Is it inteded?
> And this is quite noticeble overhead per rdma connection, btw.
> 

I'm not sure I understand your question?  What do you mean by 
"accessible"?  The intention is to _just_ reserve the addr/port.  
The socket struct alloc and bind was a simple way to do this.  I 
assume we'll have to come up with a better way though.  
Namely provide a low level interface to the port space allocator 
allowing both rdma and the host tcp stack to share the space without
requiring a socket struct for rdma connections. 

Or maybe we'll come up a different and better solution to this issue...

Steve.

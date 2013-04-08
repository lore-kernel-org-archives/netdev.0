From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH 08/16] iucv: Fix missing msg_namelen update in
 iucv_sock_recvmsg()
Date: Mon, 08 Apr 2013 13:14:19 +0200
Message-ID: <1365419659.6093.1.camel@BR9GV9YG.de.ibm.com>
References: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
	 <1365335522-29931-9-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Andy King <acking@vmware.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Dmitry Torokhov <dtor@vmware.com>,
	George Zhang <georgezhang@vmware.com>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Brad Spengler <spender@grsecurity.net>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:60621 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934522Ab3DHLO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 07:14:29 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 8 Apr 2013 12:11:37 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 741D82190071
	for <netdev@vger.kernel.org>; Mon,  8 Apr 2013 12:16:28 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r38BEDCI30015578
	for <netdev@vger.kernel.org>; Mon, 8 Apr 2013 11:14:13 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r38BEKLu006095
	for <netdev@vger.kernel.org>; Mon, 8 Apr 2013 05:14:22 -0600
In-Reply-To: <1365335522-29931-9-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-04-07 at 13:51 +0200, Mathias Krause wrote:
> The current code does not fill the msg_name member in case it is set.
> It also does not set the msg_namelen member to 0 and therefore makes
> net/socket.c leak the local, uninitialized sockaddr_storage variable
> to userland -- 128 bytes of kernel stack memory.
> 
> Fix that by simply setting msg_namelen to 0 as obviously nobody cared
> about iucv_sock_recvmsg() not filling the msg_name in case it was set.
> 
> Cc: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> ---
> Remark: I failed to test that one as I've no access to a S390 system.
> 
>  net/iucv/af_iucv.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
> index a7d11ffe..bf69358 100644
> --- a/net/iucv/af_iucv.c
> +++ b/net/iucv/af_iucv.c
> @@ -1328,6 +1328,8 @@ static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
>  	struct sk_buff *skb, *rskb, *cskb;
>  	int err = 0;
> 
> +	msg->msg_namelen = 0;
> +
>  	if ((sk->sk_state == IUCV_DISCONN) &&
>  	    skb_queue_empty(&iucv->backlog_skb_q) &&
>  	    skb_queue_empty(&sk->sk_receive_queue) &&
Acked-by: Ursula Braun <ursula.braun@de.ibm.com>

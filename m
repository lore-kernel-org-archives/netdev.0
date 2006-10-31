From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [SCTP]: Always linearise packet on input
Date: Mon, 30 Oct 2006 17:31:24 -0800
Message-ID: <1162258285.22597.33.camel@w-sridhar2.beaverton.ibm.com>
References: <20061030071128.GA15715@gondor.apana.org.au>
	 <20061029.234619.112618588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:51642 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1161520AbWJaBb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 20:31:28 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9V1VRr2013438
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 20:31:27 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9V1VRrO123176
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 20:31:27 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9V1VQJe017064
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 20:31:27 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061029.234619.112618588.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-10-29 at 23:46 -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 30 Oct 2006 18:11:28 +1100
> 
> > [SCTP]: Always linearise packet on input
>  ...
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I'll apply this, thanks a lot.
> 
> > Sridhar, could you please organise an audit of SCTP to make sure
> > that it deals with skb fragments (both pages and frag_list) in a
> > safe manner? Basically before you do an skb_pull or access skb->data
> > you must ensure that the data you want to access is in the head,
> > usually by doing skb_may_pull.  Of course, for large payloads it
> > helps if you can avoid pulling it into the head.
> 
> Of course, you mean "pskb_may_pull" here.

I think we currently assume atleast the SCTP header and the data
chunk header to be in the skb head.
But we do handle skbs with data in the frag_list.
Not sure about skb's with paged fragments.

Does XEN use frag_list or frags array?
Is there a simple way to simulate incoming packets with transport
headers and data in skb's frag_list/pages without having to use XEN.

Thanks
Sridhar


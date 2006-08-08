From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH RESEND 2/2] update sunrpc to use in-kernel sockets API
Date: Tue, 08 Aug 2006 10:19:51 -0700
Message-ID: <1155057591.26188.5.camel@w-sridhar2.beaverton.ibm.com>
References: <1154991632.11916.6.camel@w-sridhar2.beaverton.ibm.com>
	 <20060807.205910.68157131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:1921 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965006AbWHHRZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 13:25:06 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k78HOxiY031250
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 13:25:00 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k78HOx7u285420
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 13:24:59 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k78HOx0G010248
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 13:24:59 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060807.205910.68157131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-07 at 20:59 -0700, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Mon, 07 Aug 2006 16:00:32 -0700
> 
> > Update sunrpc to use in-kernel sockets API.
> > 
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> > Acked-by: James Morris <jmorris@namei.org>
> 
> Applied, thanks.
> 
> > @@ -207,7 +207,7 @@ static inline int xs_sendpages(struct so
> >  		base &= ~PAGE_CACHE_MASK;
> >  	}
> >  
> > -	sendpage = sock->ops->sendpage ? : sock_no_sendpage;
> > +	sendpage = kernel_sendpage;
> >  	do {
> >  		int flags = XS_SENDMSG_FLAGS;
> >  
> 
> Seemingly this chunk could be simplified further, by
> just invoking kernel_sendpage() directly?

We cannot do this as xs_sendpages() doesn't like to use sendpage()
with highmem pages and has the following check before making the
actual call.
                /* Hmm... We might be dealing with highmem pages */
                if (PageHighMem(*ppage))
                        sendpage = sock_no_sendpage;
                err = sendpage(sock, *ppage, base, len, flags);

Thanks
Sridhar



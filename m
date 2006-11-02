From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] warning in SCTP
Date: Thu, 02 Nov 2006 10:29:49 -0800
Message-ID: <1162492190.9660.28.camel@w-sridhar2.beaverton.ibm.com>
References: <Pine.SOC.4.61.0611020925530.1919@math.ut.ee>
	 <20061102.001643.30183952.davem@davemloft.net>
	 <20061102.003953.55508453.davem@davemloft.net>
	 <Pine.SOC.4.61.0611021119560.1919@math.ut.ee>  <454A1836.9010709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Meelis Roos <mroos@linux.ee>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:41195 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751482AbWKBSaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 13:30:00 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kA2ITqpt006550
	for <netdev@vger.kernel.org>; Thu, 2 Nov 2006 13:29:52 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kA2ITpLY248094
	for <netdev@vger.kernel.org>; Thu, 2 Nov 2006 13:29:52 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kA2ITpGr010972
	for <netdev@vger.kernel.org>; Thu, 2 Nov 2006 13:29:51 -0500
To: Vlad Yasevich <vladislav.yasevich@hp.com>
In-Reply-To: <454A1836.9010709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-02 at 11:09 -0500, Vlad Yasevich wrote:
> Meelis Roos wrote:
> >> Actually, I'm backing this one out, it creates new warnings because
> >> callers of this function pass in a "const" pointer.
> > 
> > Yes, it now seems it's not so simple. Marking it non-const there would
> > mark the it non-const in the whole family of sctp_state_fn_t and I'm not
> > sure that's the best thing to do. I guess the maintainer has better
> > bases for deciding what to do about it.
> > 
> 
> An alternate solution would be to make the digest a pointer, allocate
> it in sctp_endpoint_init() and free it in sctp_endpoint_destroy().

I agree that this is a better solution.

Acked-by: Sridhar Samudrala <sri@us.ibm.com>

Thanks
Sridhar

> 
> I guess I should have originally done it this way...
> 
> 
>   CC [M]  net/sctp/sm_make_chunk.o
> net/sctp/sm_make_chunk.c: In function 'sctp_unpack_cookie':
> net/sctp/sm_make_chunk.c:1358: warning: initialization discards qualifiers from pointer target type
> 
> The reason is that sctp_unpack_cookie() takes a const struct sctp_endpoint and modifies the digest in it
> (digest being embedded in the struct, not a pointer).  Make digest a pointer to fix this warning.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com> 
> 
> 
> 


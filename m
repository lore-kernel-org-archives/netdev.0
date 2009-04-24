From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Fri, 24 Apr 2009 08:45:28 -0400
Message-ID: <49F1B468.7020605@myri.com>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1887 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753525AbZDXMq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2009 08:46:27 -0400
In-Reply-To: <20090424054557.GA24575@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Apr 22, 2009 at 11:37:24AM -0400, Andrew Gallatin wrote:
>> I booted the sender into a kernel.org 2.6.18.2 so as to try to have  
>> results as close to yours as possible (I was running 2.6.22 on the
>> sender before).
> 
> OK I've got my hands on a myricom card.  I've tested it using the
> same 2.6.18 sender that I used against the eariler cxgb3 test.
> I wasn't able to discern any significant deviations between LRO
> and GRO.
> 
> Unfortunately it seems that this machine is a little too fast
> so even with the IRQ bound to a single CPU it's way overspeced
> for 10GbE:
> 
>     Idle at 10Gb IRQ rate	soaker IRQ rate soaker throuput
> GRO 43-45	 14700		13300		7933
> LRO 43-45	 14700		13300		7943
> 
> But even with the soaker running they seem to be neck and neck.

This is strange.  I wonder if it might be a cache footprint issue?
My intentionally weak receiver is an athlon64 x2 "Toledo", and
has only 512KB L2 cache.  I can re-test with a core-2 based Xeon.

But can you describe your setup in more detail?  What CPU does the
receiver have? You say the sender is running 2.6.18.  Is this
a RHEL5 kernel, or a kernel.org kernel?

> Here's the patch I used BTW.  I got the checksums to work by
> just setting skb->csum.

Yes, sorry about that stupidity.

Drew

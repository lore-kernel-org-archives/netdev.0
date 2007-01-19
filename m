From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Fri, 19 Jan 2007 16:20:01 +0300
Message-ID: <45B0C581.1020805@tls.msk.ru>
References: <20070119110641.GA3135@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:23234 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965127AbXASNUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 08:20:05 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070119110641.GA3135@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On 17-01-2007 15:12, Michael Tokarev wrote:
[]
>> Here's another sample, which may be more useful.  I've seen quite
>> alot of very similar stuff while running tcpdump.
>>
>>   http://www.corpit.ru/mjt/bad-cksum-session3-dmp.bin
>>
>> The scenario looks like this.
>>
>> A client (82.84.172.37 -- a zombie machine trying to send us spam
>> in this case) connects to a port 25 here (81.13.94.6:25).  SYN+ACK
>> sequence completes.  Next, our server send an initial SMTP greething
>> message, but almost right after that, the client sends a FIN packet,
>> WITHOUT acknowleging that it received the (first and only) data
>> packet.  So some time later our machine re-sends the data, AND adds
>> FIN flag to the packet (also replying to the FIN received from the
>> client).  And *that* packet - original data packet which is modified
>> to also include FIN - has incorrect checksum.
>>
>> So it looks like the checksum isn't being updated WHEN ADDING MORE
>> FLAGS to the original data packet.
>>
> 
> Hi,
> 
> Here is my patch proposal. If I'm not totally wrong,
> there is a possibility that, during collapsing, empty
> skb with FIN is added to "normal" packet and changes
> its ip_summed field to CHECKSUM_NONE.
> 
> Regards,
> Jarek P.
> 
> PS: probably there are also other possibilities...

Well..  I just tried it - with this patch applied, no more bad checksums
are shown.  Tried from the network that triggers it most reliable - and
wasn't able to reproduce the bad behavior.

I'm running a tcpdump right now, and so far it only captured a few bad-cksum
packets from other hosts (which are also running 2.6.19 ;)

Thanks Jarek!

/mjt

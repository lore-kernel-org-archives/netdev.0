From: Ben Mansell <ben@zeus.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 20 Jan 2009 12:01:13 +0000
Message-ID: <4975BD09.3020103@zeus.com>
References: <20090115.153449.204259387.davem@davemloft.net> <20090115234255.GE1123@1wt.eu> <20090115234408.GA1693@1wt.eu> <20090115.155434.206643894.davem@davemloft.net> <20090119004206.GA10396@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	jarkao2@gmail.com, zbr@ioremap.net, dada1@cosmosbay.com,
	mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.zeus.com ([212.44.21.7]:3996 "EHLO mailin.zeus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758204AbZATMBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 07:01:18 -0500
In-Reply-To: <20090119004206.GA10396@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau wrote:
> Hi guys,
> 
> On Thu, Jan 15, 2009 at 03:54:34PM -0800, David Miller wrote:
>> From: Willy Tarreau <w@1wt.eu>
>> Date: Fri, 16 Jan 2009 00:44:08 +0100
>>
>>> And BTW feel free to add my Tested-by if you want in case you merge
>>> this fix.
>> Done, thanks Willy.
> 
> Just for the record, I've now re-integrated those changes in a test kernel
> that I booted on my 10gig machines. I have updated my user-space code in
> haproxy to run a new series of tests. Eventhough there is a memcpy(), the
> results are EXCELLENT (on a C2D 2.66 GHz using Myricom's Myri10GE NICs) :
> 
>   - 4.8 Gbps at 100% CPU using MTU=1500 without LRO
>     (3.2 Gbps at 100% CPU without splice)
> 
>   - 9.2 Gbps at 50% CPU using MTU=1500 with LRO
> 
>   - 10 Gbps at 20% CPU using MTU=9000 without LRO (7 Gbps at 100% CPU without
>     splice)
> 
>   - 10 Gbps at 15% CPU using MTU=9000 with LRO
> 
> These last ones are really impressive. While I had already observed such
> performance on the Myri10GE with Tux, it's the first time I can reach that
> level with so little CPU usage in haproxy !
> 
> So I think that the memcpy() workaround might be a non-issue for some time.
> I agree it's not beautiful but it works pretty well for now.
> 
> The 3 patches I used on top of 2.6.27.10 were the fix to return 0 intead of
> -EAGAIN on end of read, the one to process multiple skbs at once, and Dave's
> last patch based on Jarek's workaround for the corruption issue.

I've also tested on the same three patches (against 2.6.27.2 here), and 
the patches appear to work just fine. I'm running a similar proxy 
benchmark test to Willy, on a machine with 4 gigabit NICs (2xtg3, 
2xforcedeth). splice is working OK now, although I get identical results 
when using splice() or read()/write(): 2.4 Gbps at 100% CPU (2% user, 
98% system).

I may be hitting a h/w limitation which prevents any higher throughput, 
but I'm a little surprised that splice() didn't use less CPU time. 
Anyway, the splice code is working which is the important part!


Ben


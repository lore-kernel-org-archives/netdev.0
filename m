From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] Revert "xen-netback: Aggregate TX unmap operations"
Date: Wed, 26 Mar 2014 10:57:02 +0000
Message-ID: <5332B27E.4040205@citrix.com>
References: <1395422584-16213-1-git-send-email-zoltan.kiss@citrix.com> <1395653207.19365.1.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395653207.19365.1.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24/03/14 09:26, Ian Campbell wrote:
> On Fri, 2014-03-21 at 17:23 +0000, Zoltan Kiss wrote:
>> This reverts commit e9275f5e2df1b2098a8cc405d87b88b9affd73e6. This commit is the
>> last in the netback grant mapping series, and it tries to do more aggressive
>> aggreagtion of unmap operations. However practical use showed almost no
>> positive effect, whilst with certain frontends it causes significant performance
>> regression.
>
> That's a shame -- do you have any insight into why?

It cause performance regression when the guest limits itself to a small 
amount of outstanding packets. E.g. with iperf on Win7 there are always 
2 in flight.
Currently batching happens in this way:
- the callback can put up to MAX_SKB_FRAGS slots into the dealloc ring 
before it wakes up the dealloc thread
- the thread doesn't schedule immediately, of course, so other callbacks 
can add to the dealloc ring in the meantime
- and even when the dealloc thread consumes the dealloc ring, the 
callbacks can put slots onto it

And my upcoming patch will avoid TLB flush in a lot of cases. If someone 
has more time to research a better strategy, that would be good, but I 
think currently it is a low priority thing.

Zoli

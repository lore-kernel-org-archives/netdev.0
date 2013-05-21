From: Pekka Riikonen <priikone@iki.fi>
Subject: Re: [PATCH v3 net-next 1/4] net: implement support
 for low latency socket polling
Date: Tue, 21 May 2013 21:31:51 +0200 (CEST)
Message-ID: <alpine.GSO.2.00.1305212123120.15328@git.silcnet.org>
References: <519B2237.20204@linux.intel.com>
	<1369142926.3301.213.camel@edumazet-glaptop>
	<alpine.GSO.2.00.1305211855120.9230@git.silcnet.org>
	<20130521.114921.460497085402760002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, eliezer.tamir@linux.intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	hpa@zytor.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, andi@firstfloor.org, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130521.114921.460497085402760002.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 21 May 2013, David Miller wrote:

> From: Pekka Riikonen <priikone@iki.fi>
> Date: Tue, 21 May 2013 19:02:19 +0200 (CEST)
>
>> On Tue, 21 May 2013, Eric Dumazet wrote:
>>
>> : > > Alternatively, use a napi_id instead of a pointer.
>> : >
>> : > I'm not sure I understand what you propose.
>> :
>> : Oh well.
>> :
>> : To get a pointer to a struct net_device, we can use ifindex, and do a
>> : rcu lookup into a hash table to get the net_device. We do not need
>> : {pointer,ifindex} but {ifindex} is enough
>> :
>> : My suggestion is to not have skb->skb_ref but skb->napi_index : Its safe
>> : to copy its value from skb->napi_index to sk->napi_index without
>> : refcounting.
>> :
>> : All NAPI need to get a unique napi_index, and be inserted in a hash
>> : table for immediate/fast lookup.
>> :
>> Maybe even that's not needed.  Couldn't skb->queue_mapping give the
>> correct NAPI instance in multiqueue nics?  The NAPI instance could be made
>> easily available from skb->dev.  In any case an index is much better than
>> a new pointer.
>
> Queue mapping is more volatile, and consider layered devices.
>
Yes, true.  The napi_index then is probably the way to go.  Main thing for 
me is that it doesn't increase skb size when in union with dma_cookie (skb 
has been growing lately).

 	Pekka


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

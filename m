From: David Miller <davem@davemloft.net>
Subject: Re: softirq warnings when calling dev_kfree_skb_irq -
 bug in conntrack?
Date: Tue, 03 Aug 2010 00:23:18 -0700 (PDT)
Message-ID: <20100803.002318.209965574.davem@davemloft.net>
References: <4C571476.7070301@goop.org>
	<1280819074.3874.8.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, Xen-devel@lists.xensource.com, Ian.Campbell@citrix.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dongxiao.xu@intel.com, kaber@trash.net
To: johannes@sipsolutions.net
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1280819074.3874.8.camel@jlt3.sipsolutions.net>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 03 Aug 2010 09:04:34 +0200

> I had this too:
> http://article.gmane.org/gmane.linux.network/167590
> 
> But I'm not convinced it's conntrack, I'd think it's
> 
> commit 15e83ed78864d0625e87a85f09b297c0919a4797
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Wed May 19 23:16:03 2010 +0000
> 
>     net: remove zap_completion_queue
> 
> which, from the looks of it, ought to be reverted because it failed to
> take into account that dev_kfree_skb() can do more things that require
> non-irq-context than just calling skb->destructor, like for instance the
> conntrack thing we see here.

Agreed.  I'll revert this and queue that up for 2.6.35-stable

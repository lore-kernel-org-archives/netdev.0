From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: Re: [PATCH 2/2] net: make net and forcedeth to use kmalloc_node
Date: Tue, 03 Jul 2007 14:28:50 -0700
Message-ID: <468ABF92.5030800@sun.com>
References: <200706291330.37070.yinghai.lu@sun.com>
 <20070703115840.e05a0f47.akpm@linux-foundation.org>
 <20070703120430.4dcbba68@freepuppy.localdomain.hemminger.net>
Reply-To: Yinghai.Lu@Sun.COM
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>,
	Greg KH <greg@kroah.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761841AbXGCV00@vger.kernel.org>
In-reply-to: <20070703120430.4dcbba68@freepuppy.localdomain.hemminger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 3 Jul 2007 11:58:40 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> On Fri, 29 Jun 2007 13:30:36 -0700
>> Yinghai Lu <Yinghai.Lu@Sun.COM> wrote:
>>
>>> [PATCH 2/2] net: make net and forcedeth to use kmalloc_node
>> Please copy netdev@vger.kernel.org on net patches.
>>
>> This patch modifies a net driver as well as the networking core.  These
>> subsytems have different maintainers who run different development trees. 
>> Consequently I must split your patch into two and change their titles and
>> changelogs appropriately.
>>
>> Please do this for us in future, thanks.
>>
>>
>>> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
>>> index 42ba1c0..6d53b52 100644
>>> --- a/drivers/net/forcedeth.c
>>> +++ b/drivers/net/forcedeth.c
>>> @@ -1383,7 +1383,7 @@ static int nv_alloc_rx(struct net_device *dev)
>>>  		less_rx = np->last_rx.orig;
>>>  
>>>  	while (np->put_rx.orig != less_rx) {
>>> -		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
>>> +		struct sk_buff *skb = dev_alloc_skb_node(np->rx_buf_sz + NV_RX_ALLOC_PAD, dev_to_node(&dev->dev));
>> If we're going to do this then it would probably make sense to change
>> dev_alloc_skb_node() so that it takes a `struct net_device *' rather than a
>> bare node-id.  That's a call which the net guys will need to make, which is
>> why we cc them on our emails.
> 
> The driver should use netdev_alloc_skb. That routine is supposed to be overriden
> on architecture's that need per node changes.

do you mean:
use dev_alloc_skb_node for numa arch.
and other non numa will use macro or static inline to dev_alloc_skb

YH

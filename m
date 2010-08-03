From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: softirq warnings when calling dev_kfree_skb_irq - bug in conntrack?
Date: Tue, 03 Aug 2010 12:16:39 -0700
Message-ID: <4C586B17.8090604@goop.org>
References: <4C571476.7070301@goop.org>	<1280819074.3874.8.camel@jlt3.sipsolutions.net> <20100803.002318.209965574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	dongxiao.xu@intel.com, Xen-devel@lists.xensource.com,
	Ian.Campbell@citrix.com, kaber@trash.net, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claw.goop.org ([74.207.240.146]:58956 "EHLO claw.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753672Ab0HCTQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 15:16:46 -0400
In-Reply-To: <20100803.002318.209965574.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  On 08/03/2010 12:23 AM, David Miller wrote:
> From: Johannes Berg<johannes@sipsolutions.net>
> Date: Tue, 03 Aug 2010 09:04:34 +0200
>
>> I had this too:
>> http://article.gmane.org/gmane.linux.network/167590
>>
>> But I'm not convinced it's conntrack, I'd think it's
>>
>> commit 15e83ed78864d0625e87a85f09b297c0919a4797
>> Author: Eric Dumazet<eric.dumazet@gmail.com>
>> Date:   Wed May 19 23:16:03 2010 +0000
>>
>>      net: remove zap_completion_queue
>>
>> which, from the looks of it, ought to be reverted because it failed to
>> take into account that dev_kfree_skb() can do more things that require
>> non-irq-context than just calling skb->destructor, like for instance the
>> conntrack thing we see here.
> Agreed.  I'll revert this and queue that up for 2.6.35-stable

Reverting this change fixes the problem for me.

Thanks,
     J


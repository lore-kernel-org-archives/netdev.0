From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next] ixgbe: flush when in xmit_more mode and under
 descriptor pressure
Date: Thu, 28 Aug 2014 13:46:09 +0200
Message-ID: <53FF1681.7030406@redhat.com>
References: <1409074458-17989-1-git-send-email-dborkman@redhat.com> <20140827.231814.2270210172570593864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6554 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607AbaH1LqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2014 07:46:13 -0400
In-Reply-To: <20140827.231814.2270210172570593864.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2014 08:18 AM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Tue, 26 Aug 2014 19:34:18 +0200
>
>> When xmit_more mode is being used and the ring is about to
>> become full or the stack has stopped the ring, enforce a tail
>> pointer write to the hw. Otherwise, we could risk a TX hang.
>>
>> Code suggested by Alexander Duyck.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   v1->v2:
>>    - Worked in Alex' feedback; in accordance w/ Alex, sending out v2
>>    - Rerun tests, looks good
>
> Applied, thanks Daniel.
>
> I'll make similar mods to igb and vhost_net soon.

Cool, at some point later, we might want to put ...

   netif_xmit_stopped(<tx_ring>) || !skb->xmit_more

... into an API perhaps, but that can likely wait right now.

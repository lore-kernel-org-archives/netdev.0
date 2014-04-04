From: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Subject: Re: [RFC PATCH] veth: keep peers MTU values synchronized
Date: Fri, 4 Apr 2014 18:42:29 +0400
Message-ID: <533EC4D5.50304@securitycode.ru>
References: <533DD390.6020103@gmail.com> <20140404.102518.2263545144702348056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <matvejchikov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from itna.infosec.ru ([82.198.190.199]:25494 "EHLO itna.infosec.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386AbaDDOlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 10:41:50 -0400
In-Reply-To: <20140404.102518.2263545144702348056.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.04.2014 18:25, David Miller wrote:
> From: "Ilya V. Matveychikov" <matvejchikov@gmail.com>
> Date: Fri, 04 Apr 2014 01:33:04 +0400
> 
>> Keep peers MTU values synchronized. That prevent dropping packets
>> while
>> forwarding as diffirent MTU values prevent skb moving from one peer's
>> device to another (is_skb_forwardable returns false).
>>
>> Signed-off-by: Ilya V. Matveychikov <i.matveychikov@securitycode.ru>
> 
> Such side effects on another device when changing the configuration
> of one are strongly discouraged.
> 

Devices are paired. It means that one depends on another. Is there any case
where this "side" effect wouldn't be helpful?

> Furthermore, when the veth peer is created, no attempt is made to
> synchronize the MTUs.

Peers are created at once and ether_setup used for the configuration so MTU
values equals.

> 
> Let it therefore be the admins responsibility to keep them in sync
> just as it would be on a real network.
> 
> 

Different MTU values for the veth pairs are meaningless as if so we can't do the
communication between the namespaces at all. So, is it correct to shift all the
configuration problems to admins?

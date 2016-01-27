From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] net:Add sysctl_tcp_sg_max_skb_frags
Date: Wed, 27 Jan 2016 19:12:12 +0100
Message-ID: <56A9087C.20305@stressinduktion.org>
References: <568F87AC.60405@oracle.com>
 <1453900829-3384-1-git-send-email-hans.westgaard.ry@oracle.com>
 <1453907702.20722.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	Haakon Bugge <haakon.bugge@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:50028 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933924AbcA0SMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 13:12:17 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 0183220C87
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 13:12:16 -0500 (EST)
In-Reply-To: <1453907702.20722.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.01.2016 16:15, Eric Dumazet wrote:
> On Wed, 2016-01-27 at 14:20 +0100, Hans Westgaard Ry wrote:
>> Devices may have limits on the number of fragments in an skb they support.
>> Current codebase uses a constant as maximum for number of fragments one
>> skb can hold and use.
>> When enabling scatter/gather and running traffic with many small messages
>> the codebase uses the maximum number of fragments and may thereby violate
>> the max for certain devices.
>> The patch introduces a global variable as max number of fragments in
>> scatter/gather.
>
>
> Principle looks good, but we have to ask if other skb providers [1] will
> add other sysctl, or if we could share a common one ?
>
> If it is a common one, it should be /proc/sys/net/core/... instead
> of /proc/sys/net/ipv4/tcp_....
 >
> Other providers include :
>
> 1) GRO stack
> 2) callers of sock_alloc_send_pskb(), alloc_skb_with_frags(),
> sock_alloc_send_skb() ..

I agree, this knob should get a generic name and live in a generic net/ 
directory to control this globally, so things don't break during 
forwarding etc.

It does not solve the problem completely, e.g. when VMs send gso packets 
through a vhost-net onto IPoIB, no?

Thanks,
Hannes

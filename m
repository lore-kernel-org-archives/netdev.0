From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Tue, 22 Jul 2008 14:48:42 +0200
Message-ID: <4885D72A.1060106@trash.net>
References: <Pine.LNX.4.64.0807212100580.1760@ranjit.corp.google.com>	 <4885B7DD.7070507@trash.net> <6599ad830807220514m5afea0fcsb99bf2e95f401c36@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ranjit Manomohan <ranjitm@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com
To: Paul Menage <menage@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61591 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbYGVMsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 08:48:47 -0400
In-Reply-To: <6599ad830807220514m5afea0fcsb99bf2e95f401c36@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Menage wrote:
> On Tue, Jul 22, 2008 at 6:35 AM, Patrick McHardy <kaber@trash.net> wrote:
>> Does this really have to be a new skb member? You could
>> simply use skb->sk->sk_cgroup_classid directly, or if
>> that doesn't work, maybe skb->priority.
>>
> 
> We were actually using skb->priority in our internal version of this
> patch. I suggested that the separate cgroup_classid field be added
> since it might be considered an abuse of skb->priority and would
> interfere with existing users of that. If that's not an issue then
> reusing skb->priority is certainly possible.

Using skb->priority for classification would be fine, but it would
probably interfere with the default initialization to sk->sk_priority.

> Regarding skb->sk->sk_cgroup_classid, is it always the case that the
> original sk is still available when we're making traffic control
> decisions? I'd thought that there were cases (e.g. cloning skbs in the
> TCP retransmit path) where the pointer to the original sk is lost.

After cloning, TCP sets the owner of the skb to the socket, so
that should work fine.

From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
Date: Wed, 30 Sep 2015 10:54:29 +0200
Message-ID: <560BA345.40504@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
 <1443525140-13493-4-git-send-email-daniel@zonque.org>
 <20150929211959.GF19923@breakpoint.cc> <560B8E25.7050801@zonque.org>
 <alpine.LSU.2.20.1509300938060.9960@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, pablo@netfilter.org,
	daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, balazs.scheidler@balabit.com
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:39459 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752644AbbI3Iyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 04:54:32 -0400
In-Reply-To: <alpine.LSU.2.20.1509300938060.9960@nerf40.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2015 09:40 AM, Jan Engelhardt wrote:
> 
> On Wednesday 2015-09-30 09:24, Daniel Mack wrote:
>>
>>> Drop?  Makes no sense, else application would not be running in the first
>>> place.
>>
>> Of course you can drop certain packets at this point, depending on other
>> details. Say, for instance, you want to match all packets that are
>> received by a certain task [...]
>> Another use case is accounting. If you want to know how much traffic a
>> certain service or application in your system has caused
> 
> But the sk info would be available in INPUT already, would it not?

No, only for established connections, as those are subject to early
demux which sets skb->sk. For all other packets, netfilter callbacks are
called with skb->sk == NULL.

That's the whole point of this patch set ;)


Daniel

From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCHv1 net-next] xen-netback: remove unconditional
 pull_skb_tail in guest Tx path
Date: Wed, 5 Nov 2014 10:46:37 +0000
Message-ID: <545A000D.8070808@citrix.com>
References: <1415036346.1411.3.camel@citrix.com>	 <5457BF80.2000205@citrix.com> <5457C807.5080509@linaro.org>	 <20141104.161704.1690311989900127361.davem@davemloft.net> <1415137397.25370.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <zoltan.kiss@linaro.org>, <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>, <malcolm.crossley@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:15470 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754466AbaKEKqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 05:46:54 -0500
In-Reply-To: <1415137397.25370.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/14 21:43, Eric Dumazet wrote:
> On Tue, 2014-11-04 at 16:17 -0500, David Miller wrote:
> 
> 
>>
>> Every protocol demux starts with pskb_may_pull() to pull frag data
>> into the linear area, if necessary, before looking at headers.
> 
> eth_get_headlen() might be relevant as well, to perform a single copy of
> exactly all headers.

In netback's case we need an estimate of the header length before
reading any of the packet, since peeking at any frag would prevent any
TLB flush avoidance.

It might be useful to use eth_get_headlen() to adjust the estimate at
runtime, but for now the fixed amount of 128 bytes is simple and seems
good enough.

David

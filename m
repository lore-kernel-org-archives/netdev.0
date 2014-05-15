From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: Moving frags and SKBTX_DEV_ZEROCOPY skbs
Date: Thu, 15 May 2014 18:14:26 +0100
Message-ID: <5374F5F2.9000807@citrix.com>
References: <53737266.5040601@citrix.com> <1400077432.7973.85.camel@edumazet-glaptop2.roam.corp.google.com> <5373C701.1080301@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	<kvm@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:8027 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752685AbaEORO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 13:14:29 -0400
In-Reply-To: <5373C701.1080301@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/05/14 20:41, Zoltan Kiss wrote:
> But here is the thing: deliver_skb calls orphan_frags for every packet
> delivered to the local stack, so we are safe IF these functions are
> called before the IP stack. So we are safe now, but things can go wrong,
> if:
> - such a frag-mangling function is called before deliver_skb, now or in
> the future
> - if someone wants to take advantage of zerocopy in the guest<->backend
> path

Running through the code I've found the following core functions can 
shuffle frags between skbs (and don't handle zerocopy skbs already):
skb_gro_receive
skb_shift
skb_split

None of them can meet at the moment with zerocopy skbs, but it's better 
to keep it in mind for the future, that would blow up these kind of skbs.

Zoli

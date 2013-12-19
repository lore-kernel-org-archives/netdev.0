From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: ixgbevf: suspicious skb->pkt_type check
Date: Thu, 19 Dec 2013 12:35:20 -0800
Message-ID: <52B35888.9050506@intel.com>
References: <CAGVrzcbYgy--jh_C6op39+DZqqkS5=Dmuu57uUGSnEr0TZ6DUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43146 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755958Ab3LSUfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 15:35:22 -0500
In-Reply-To: <CAGVrzcbYgy--jh_C6op39+DZqqkS5=Dmuu57uUGSnEr0TZ6DUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2013 10:08 AM, Florian Fainelli wrote:
> Hi John,
>
> In commit 815cccbf ("ixgbe: add setlink, getlink support to ixgbe and
> ixgbevf") this line was added:
>
>
> +               if ((skb->pkt_type & (PACKET_BROADCAST | PACKET_MULTICAST)) &&
> +                   !(compare_ether_addr(adapter->netdev->dev_addr,
> +                                       eth_hdr(skb)->h_source))) {
>
> This looks suspicious to me since skb->pkt_type is not a bitmask, but
> holds only one value at a time,  and with this check you would also
> match any value which has the lower two bits set, so PACKET_OTHERHOST,
> PACKET_LOOPBACK and PACKET_FASTROUTE are also matching the first part
> of the check.
>

Yep, it is poorly coded I'll send a fix to Jeff to make it readable.

Note it doesn't actually break anything in practice because the only
types that can be set at this point are broadcast, multicast or
otherhost. And because this virtual function is behind the embedded
switch in the nic only packets with the correct destination address
or multicast addresses will make it to the virtual function. The
virtual function doesn't currently support promisc mode further promisc
mode in the context of a switch that doesn't support flooding is sort
of non-sense to start with. All that said a much better check would
be 'if (skb->pkt_type && ...) ' thanks for catching it.

Thanks,
John

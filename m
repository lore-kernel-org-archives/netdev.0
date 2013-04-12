From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 02/11] ixgbe: Mask off check of frag_off as we only
 want fragment offset
Date: Fri, 12 Apr 2013 09:38:28 -0700
Message-ID: <51683884.2010509@intel.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1365765866-15741-3-git-send-email-jeffrey.t.kirsher@intel.com>  <1365773328.4459.19.camel@edumazet-glaptop> <1365774332.4459.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49747 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754728Ab3DLQia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 12:38:30 -0400
In-Reply-To: <1365774332.4459.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2013 06:45 AM, Eric Dumazet wrote:
> On Fri, 2013-04-12 at 06:28 -0700, Eric Dumazet wrote:
>
>> I wonder if you could use core functions instead of all this...
>>
>> A simple wrapper would be :
> Or more something like :
>
> static noinline unsigned int ixgbe_get_headlen(unsigned char *data,
>                                                 u32 maxlen)
> {
>     struct skb fake;
>     unsigned int res;
>
>     if (maxlen < ETH_HLEN)
> 	return maxlen;
>
>     fake->data = data + ETH_HLEN;
>     fake->head = data;
>     fake->data_len = 0;
>     fake->len = maxlen - ETH_HLEN;
>     skb_reset_network_header(&fake);
>     res = __skb_get_poff(&fake);
>     return res ? res + ETH_HLEN : maxlen;
> }

The problem is this is way more then I need, and I would prefer not to
allocate a 192+ byte structure on the stack in order to just parse a
header that is likely less than 128 bytes.

I could probably do something like create a copy of the
ixgbe_get_headlen function, maybe named something like
etherdev_get_headlen and stored in eth.c that could be used by both igb
and ixgbe.  That way it would be available for anyone else who might
want to do something similar.  If that would work for you I could
probably submit that patch sometime in the next few hours.

Thanks,

Alex

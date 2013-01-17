From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 09/14] igb: Report L4 Rx hash via skb->l4_rxhash
Date: Thu, 17 Jan 2013 09:23:10 -0800
Message-ID: <50F8337E.9030302@intel.com>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1358422519-20981-10-git-send-email-jeffrey.t.kirsher@intel.com>  <1358432385.29723.6.camel@edumazet-glaptop>  <50F82FCA.9090709@intel.com> <1358442889.29723.58.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49302 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152Ab3AQRXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 12:23:11 -0500
In-Reply-To: <1358442889.29723.58.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2013 09:14 AM, Eric Dumazet wrote:
> On Thu, 2013-01-17 at 09:07 -0800, Alexander Duyck wrote:
> 
>> Isn't the same true of TCP?  I believe STT is intended to run over the
>> TCP protocol, or am I getting ahead of myself since STT is not supported
>> by the kernel?
>>
> 
> probably ;)
> 
>>> Also, is IGB really using the ports in the rss for UDP packets ?
>>
>> Not by default.  The default is to only hash on the IP header for UDP
>> packets.
>>
>> As such the default would only be setting the l4_rxhash on TCP frames
>> only.  The user would have to specifically request L4 port hashing for
>> UDP via the "ethtool -N" command for configuring rx-flow-hash.
> 
> So you should rewrite this patch ?
> 
> Or have I missed something ?

I'm probably going to scrap it.  No point in rewriting it.

I has assumed that there were other uses for the l4_rxhash value.  If
all it is meant for is to indicate that the inner header of a tunnel was
used to compute the hash then there isn't much point to adding support
for this in igb/ixgbe since they don't support any inner header hashing.

It might add value at some point to rename the l4_rxhash flag to
something else though since it seems like there are now tunnels that are
encapsulated inside of l4 headers and it is going to get confusing.

Thanks,

Alex

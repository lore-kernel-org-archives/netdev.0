From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v9 net-next 5/7] net: simple poll/select low latency socket
 poll
Date: Wed, 05 Jun 2013 17:56:19 +0300
Message-ID: <51AF5193.1060209@linux.intel.com>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com>  <20130605103452.11172.31453.stgit@ladj378.jer.intel.com>  <1370439054.24311.248.camel@edumazet-glaptop>  <51AF401C.2030506@linux.intel.com>  <1370440607.24311.251.camel@edumazet-glaptop> <1370441849.24311.256.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370441849.24311.256.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/06/2013 17:17, Eric Dumazet wrote:
> On Wed, 2013-06-05 at 06:56 -0700, Eric Dumazet wrote:
>
>> This looks quite easy, by adding in include/uapi/asm-generic/poll.h
>>
>> #define POLL_LL 0x8000
>>
>> And do the sk_poll_ll() call only if flag is set.
>>
>> I do not think we have to support select(), as its legacy interface, and
>> people wanting ll should really use epoll() or poll().
>
> Alternatively, add a per socket flag to enable/disable ll
>
> This global enable assumes the application owns the host anyway.
>

I plan on adding a socket option in the next stage.
I'm also testing a patch much like you described with a poll flag.
Select/poll set it to indicate that they want to busy poll.
Sock_poll sets it to indicate that this socket can (at the moment)
busy-poll.

If you think the way things are done right now is unacceptable,
even as an experimental feature, I would much prefer to drop this patch
and have the rest applied rather then bring in new code that is not 
fully tested at this stage.

-Eliezer

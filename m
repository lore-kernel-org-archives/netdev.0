From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH v10 net-next 2/6] net: add low latency socket poll
Date: Mon, 10 Jun 2013 12:36:37 -0400
Message-ID: <CA+FuTSfvShAH4EfDpM+4Ur_H5O=phKax-Xee9iLD3O4SUYiH8w@mail.gmail.com>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
 <20130610083950.6955.9813.stgit@ladj378.jer.intel.com> <1370874576.3252.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370874576.3252.3.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 10, 2013 at 10:29 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-06-10 at 11:39 +0300, Eliezer Tamir wrote:
>> Adds an ndo_ll_poll method and the code that supports it.
>> This method can be used by low latency applications to busy-poll
>> Ethernet device queues directly from the socket code.
>> sysctl_net_ll_poll controls how many microseconds to poll.
>> Default is zero (disabled).
>> Individual protocol support will be added by subsequent patches.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> ---
>>
>>  Documentation/sysctl/net.txt |    7 ++
>>  include/linux/netdevice.h    |    3 +
>>  include/linux/skbuff.h       |    8 ++
>>  include/net/ll_poll.h        |  148 ++++++++++++++++++++++++++++++++++++++++++
>>  include/net/sock.h           |    4 +
>>  include/uapi/linux/snmp.h    |    1
>>  net/Kconfig                  |   12 +++
>>  net/core/skbuff.c            |    4 +
>>  net/core/sock.c              |    6 ++
>>  net/core/sysctl_net_core.c   |   10 +++
>>  net/ipv4/proc.c              |    1
>>  net/socket.c                 |    6 ++
>>  12 files changed, 208 insertions(+), 2 deletions(-)
>>  create mode 100644 include/net/ll_poll.h
>
> Acked-by: Eric Dumazet <edumazet@google.com>
>

Tested-by: Willem de Bruijn <willemb@google.com>

Per Eliezer's request, I applied v10 to a small set of workloads
(netperf tcp_rr, udp_rr, 100x tcp_rr, 100x udp_rr and a poll()-based
tcp rr) for some functional testing.

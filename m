From: Marc Aurele La France <tsi@ualberta.ca>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Tue, 24 Aug 2010 14:33:02 -0600 (Mountain Daylight Time)
Message-ID: <alpine.WNT.2.00.1008241422540.312@cluij.ucs.ualberta.ca>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca> <20100823080543.319143e3@nehalam> <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca> <1282672647.2302.15.camel@achroite.uk.solarflarecom.com> <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
 <1282680572.2467.78.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1152640-27923-1282681983=:312"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282680572.2467.78.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1152640-27923-1282681983=:312
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT

On Tue, 24 Aug 2010, Eric Dumazet wrote:
> Le mardi 24 août 2010 à 13:49 -0600, Marc Aurele La France a écrit :
>> Any payload has to either fit in the MTU, or has to be broken up into
>> MTU-sized (or less) fragments, come hell or high water.  That this is done
>> centrally is a good thing.  It is the "(or less)" part that I am working
>> towards here.

> Could you post a full stack trace, to help me understand the path from
> NFS to ip_append_data ?

  [<ffffffff810a5abe>] __alloc_pages_nodemask+0x617/0x692
  [<ffffffff81061688>] ? mark_held_locks+0x49/0x64
  [<ffffffff810d018b>] kmalloc_large_node+0x61/0x9e
  [<ffffffff810d3050>] __kmalloc_node_track_caller+0x32/0x159
  [<ffffffff812612da>] ? sock_alloc_send_pskb+0xc9/0x2ea
  [<ffffffff81265cc6>] __alloc_skb+0x74/0x163
  [<ffffffff812612da>] sock_alloc_send_pskb+0xc9/0x2ea
  [<ffffffff81061688>] ? mark_held_locks+0x49/0x64
  [<ffffffff81261510>] sock_alloc_send_skb+0x15/0x17
  [<ffffffff81299317>] ip_append_data+0x500/0x9d0
  [<ffffffff8103feae>] ? local_bh_enable+0xb7/0xbd
  [<ffffffff8129a804>] ? ip_generic_getfrag+0x0/0x92
  [<ffffffff81292bcd>] ? ip_route_output_flow+0x82/0x1f9
  [<ffffffff812b8990>] udp_sendmsg+0x4ec/0x60c
  [<ffffffff812bf2ac>] inet_sendmsg+0x4b/0x58
  [<ffffffff8125dd89>] sock_sendmsg+0xd9/0xfa
  [<ffffffff81063fb0>] ? __lock_acquire+0x787/0x7f5
  [<ffffffff81063fb0>] ? __lock_acquire+0x787/0x7f5
  [<ffffffff8125fcf5>] kernel_sendmsg+0x37/0x43
  [<ffffffffa0267cd2>] xs_send_kvec+0x88/0x93 [sunrpc]
  [<ffffffff812f08dc>] ? _raw_spin_unlock_irqrestore+0x44/0x4c
  [<ffffffffa0267d5c>] xs_sendpages+0x7f/0x1be [sunrpc]
  [<ffffffffa026952f>] xs_udp_send_request+0x5b/0x103 [sunrpc]
  [<ffffffffa0266c0a>] xprt_transmit+0x11f/0x1f5 [sunrpc]
  [<ffffffffa02ea140>] ? nfs3_xdr_writeargs+0x0/0x82 [nfs]
  [<ffffffffa02648b9>] call_transmit+0x218/0x25e [sunrpc]
  [<ffffffffa026aced>] __rpc_execute+0x9b/0x288 [sunrpc]
  [<ffffffffa026aeef>] rpc_async_schedule+0x15/0x17 [sunrpc]
  [<ffffffff81051137>] worker_thread+0x1ed/0x2e6
  [<ffffffff810510e1>] ? worker_thread+0x197/0x2e6
  [<ffffffffa026aeda>] ? rpc_async_schedule+0x0/0x17 [sunrpc]
  [<ffffffff8105450f>] ? autoremove_wake_function+0x0/0x3d
  [<ffffffff81050f4a>] ? worker_thread+0x0/0x2e6
  [<ffffffff810541b2>] kthread+0x82/0x8a
  [<ffffffff81002f14>] kernel_thread_helper+0x4/0x10
  [<ffffffff81030d20>] ? finish_task_switch+0x0/0xd6
  [<ffffffff81002f10>] ? kernel_thread_helper+0x0/0x10

There are many other variations as well.

> I suspect this is UDP transport ?

Yes.

> This reminds me a patch I wrote for IPV6 : We were allocating a huge
> (MTU sized) buffer, just to fill few bytes in it...

Humm.  Interesting.  Thanks for the pointer.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi@ualberta.ca         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
--1152640-27923-1282681983=:312--

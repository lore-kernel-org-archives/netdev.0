From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH v8 net-next 0/7] net: low latency Ethernet device polling
Date: Mon, 3 Jun 2013 14:23:44 +0300
Message-ID: <51AC7CC0.6020205@mellanox.com>
References: <20130603080107.18273.34279.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	<e1000-devel@lists.sourceforge.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:59245 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755992Ab3FCL0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 07:26:53 -0400
In-Reply-To: <20130603080107.18273.34279.stgit@ladj378.jer.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-By: Amir Vadai <amirv@mellanox.com>

Nice work Eliezer :)

On 03/06/2013 11:01, Eliezer Tamir wrote:
> David,
> 
> Here is v8 with yet more fixes.
> 
> Please consider applying.
> 
> Thanks to everyone for their input.
> 
> -Eliezer
> 
> change log:
> v8
> - split out udp and select/poll into seperate patches.
>   what used to be patch 2/5 is now three patches.
> - type corrections from Amir Vadai and Cong Wang:
>   one unsigned long that was left when chenging to cycles_t
>   int -> bool 
> - more detailed patch descriptions.
> 
> v7
> - suggested by Ben Hutchings and Eric Dumazet:
>   type fixes, static for globals in net/core.c,
>   avoid napi_id collisions in napi_hash_add()
> 
> v6
> - many small fixes suggested by Eric Dumazet:
>   data locality, typos, documentation
>   protect napi_hash insert/delete with a spinlock (napi_gen_id is no
>   longer atomic_t since it's only accessed with the spinlock held.)
> - added IPv6 TCP and UDP support (only minimally tested)
> 
> v5
> - corrections suggested by Ben Hutchings:
>   fixed typos, moved the config option and sysctl value from IPv4 to net
> - moved sk_mark_ll() to the protocol handlers
> - removed global id mechanism, replaced with a hashed napi_id.
>   based on code sample from Eric Dumazet
>   Note that ixgbe_free_q_vector() already waits an rcu grace period
>   before freeing the q_vector, so nothing additional needs to be done
>   when adding a call to napi_hash_del().
> - simple poll/select support
> 
> v4
> - removed separate config option for TCP as suggested Eric Dumazet.
> - added linux mib counter for packets received through the low latency path,
>   as suggested by Andi Kleen.
> - re-allow module unloading, remove module param, use a global generation id
>   instead to prevent the use of a stale napi pointer, as suggested
>   by Eric Dumazet
> - updated Documentation/networking/ip-sysctl.txt text
> 
> v3
> - coding style changes suggested by Dave Miller
> 
> v2
> - the sysctl knob is now in microseconds. The default value is now 0 (off).
> - for now the code depends at configure time on CONFIG_I86_TSC 
> - the napi reference in struct skb is now a union with the dma cookie
>   since the former is only used on RX and the latter on TX,
>   as suggested by Eric Dumazet.
> - we do a better job at honoring non-blocking operations.
> - removed busy-polling support for tcp_read_sock()
> - remove dynamic disabling of GRO
> - coding style fixes
> - disallow unloading the device module after the feature has been used
> 
> Credit:
> Jesse Brandeburg, Arun Chekhov Ilango, Julie Cummings,
> Alexander Duyck, Eric Geisler, Jason Neighbors, Yadong Li,
> Mike Polehn, Anil Vasudevan, Don Wood
> Special thanks for finding bugs in earlier versions:
> Willem de Bruijn and Andi Kleen
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

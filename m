From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: (usagi-core 14846) [PATCH] IPv6: No fragmentation of packets
 with length <= mtu
Date: Wed, 06 Aug 2003 19:28:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030806.192824.129498139.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0308061039550.1401-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0308061039550.1401-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0308061039550.1401-200000@rhea.tcs.hut.fi> (at Wed, 6 Aug 2003 13:00:41 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> I noticed ip6_append_data() always reserves space for the fragment header
> at the cost of the payload data. This leads to the unnecessary
> fragmentation of packets with lengths close (or equal) to the link-mtu.
> This can for example be seen with ping6 -s 1448 (on an ethernet link).
> 
> My attached patch _seems_ to fix the problem without breaking anything
> else, but can you still verify this?

Well, your patch breaks something; the idea of append_data.
User may "push" multiple times to generate a packet.

I'm chasing this bug.
Since this bug is not grave, we do not need to fix this ASAP;
We need to fix a grave issue with UDPv6 with MSG_MORE flag 
before this.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

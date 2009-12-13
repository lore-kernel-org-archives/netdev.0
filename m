From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: nfs broken in net-next? -- now in mainline -- bisected:
	d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
Date: Sat, 12 Dec 2009 17:57:51 -0800
Message-ID: <86802c440912121757g474a7df4od6b50f6d5a210cf0@mail.gmail.com>
References: <86802c440912112125v4aa72189ifcc2d16ecbf79cc4@mail.gmail.com>
	 <20091211.214117.200029438.davem@davemloft.net>
	 <86802c440912121705y59eea3ebq3bdbd3e7459e748e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: mingo@elte.hu, sri@us.ibm.com, herbert@gondor.apana.org.au,
	torvalds@linux-foundation.org, sjayaraman@suse.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:43463 "HELO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S933426AbZLMB5w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2009 20:57:52 -0500
In-Reply-To: <86802c440912121705y59eea3ebq3bdbd3e7459e748e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 12, 2009 at 5:05 PM, Yinghai Lu <yinghai@kernel.org> wrote:
>
> [f86dcc5aa8c7908f2c287e7a211228df599e3e71] udp: dynamically
> size hash tables at boot time

commit f86dcc5aa8c7908f2c287e7a211228df599e3e71
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed Oct 7 00:37:59 2009 +0000

    udp: dynamically size hash tables at boot time

    UDP_HTABLE_SIZE was initialy defined to 128, which is a bit small for
    several setups.

    4000 active UDP sockets -> 32 sockets per chain in average. An
    incoming frame has to lookup all sockets to find best match, so long
    chains hurt latency.

    Instead of a fixed size hash table that cant be perfect for every
    needs, let UDP stack choose its table size at boot time like tcp/ip
    route, using alloc_large_system_hash() helper

    Add an optional boot parameter, uhash_entries=x so that an admin can
    force a size between 256 and 65536 if needed, like thash_entries and
    rhash_entries.

    dmesg logs two new lines :
    [    0.647039] UDP hash table entries: 512 (order: 0, 4096 bytes)
    [    0.647099] UDP Lite hash table entries: 512 (order: 0, 4096 bytes)

    Maximal size on 64bit arches would be 65536 slots, ie 1 MBytes for non
    debugging spinlocks.

    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

cause the problem: nfs mount fail.

the setup is:
64bit kernel, have all needed drivers in kernel, and boot with
ip=dhcp, root disk is 256M ramdisk.
then try to mount nfs....

YH

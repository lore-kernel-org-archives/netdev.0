From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ipv4: warnings on sk_wmem_queued
Date: Sat, 31 Aug 2013 06:44:30 +0000
Message-ID: <20130831064430.GA9903@dcvr.yhbt.net>
References: <20130830195638.GA27393@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130830195638.GA27393@dcvr.yhbt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Wong <normalperson@yhbt.net> wrote:
> I noticed these warnings on stock 3.10.9 running stress tests on
> cmogstored.git (git://bogomips.org/cmogstored.git) doing standard
> HTTP server stuff between lo and tmpfs:

I'm still running the same test (in-place upgraded cmogstored a few
times to fix some bugs), and haven't hit these warnings again
(constantly pushing around 20GB/s total).

I forget to mention cmogstored is multithreaded and idle clients
automatically migrate between threads when becoming active (using
EPOLLONESHOT), so maybe this tickles some rare race condition
somewhere...

> Aug 30 06:03:54 localhost kernel: WARNING: at net/core/stream.c:200 sk_stream_kill_queues+0x131/0x140()
<snip>
> Aug 30 06:03:54 localhost kernel: WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x191/0x1e0()

I probably won't be in a good position to reboot/test patches until
Tuesday, though.

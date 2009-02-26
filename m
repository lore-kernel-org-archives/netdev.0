From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: Kernel problem
Date: Thu, 26 Feb 2009 11:38:13 +0200
Message-ID: <200902261138.13485.denys@visp.net.lb>
References: <20090226093902.GA12753@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Denis Romanenko <ash@sevsky.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:58636 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbZBZKB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 05:01:57 -0500
In-Reply-To: <20090226093902.GA12753@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I spoke with Denis Romanenko (i know him)

Here is some additional info:
First of all, he booted kernel with extensive debug options. He was not able 
to run it for long time, because performance of router degraded too much.

Here is part of script where all things happened

# Disk discipline
echo cfq > /sys/block/sda/queue/scheduler

# Irq for cards
echo 4 >/proc/irq/215/smp_affinity
echo 8 >/proc/irq/214/smp_affinity
echo 1 >/proc/irq/216/smp_affinity
echo 2 >/proc/irq/217/smp_affinity

# Cards setup
/usr/sbin/ethtool -G eth0 rx 1024 tx 1024
/usr/sbin/ethtool -G eth1 rx 1024 tx 1024
/usr/sbin/ethtool -G eth2 rx 1024 tx 1024
/usr/sbin/ethtool -G eth3 rx 1024 tx 1024
/usr/sbin/ethtool -C eth0 rx-usecs 3
/usr/sbin/ethtool -C eth1 rx-usecs 3
/usr/sbin/ethtool -C eth2 rx-usecs 3
/usr/sbin/ethtool -C eth3 rx-usecs 3
/usr/sbin/ethtool -K eth0 tso off
/usr/sbin/ethtool -K eth1 tso off
/usr/sbin/ethtool -K eth2 tso off
/usr/sbin/ethtool -K eth3 tso off
/usr/sbin/ethtool -K eth0 sg off
/usr/sbin/ethtool -K eth1 sg off
/usr/sbin/ethtool -K eth2 sg off
/usr/sbin/ethtool -K eth3 sg off
/usr/sbin/ethtool -K eth0 ufo off
/usr/sbin/ethtool -K eth1 ufo off
/usr/sbin/ethtool -K eth2 ufo off
/usr/sbin/ethtool -K eth3 ufo off
/usr/sbin/ethtool -K eth0 gso off
/usr/sbin/ethtool -K eth1 gso off
/usr/sbin/ethtool -K eth2 gso off
/usr/sbin/ethtool -K eth3 gso off

# interface queue
/sbin/ifconfig eth0 txqueuelen 10000
/sbin/ifconfig eth1 txqueuelen 10000
/sbin/ifconfig eth2 txqueuelen 10000
/sbin/ifconfig eth3 txqueuelen 10000


On Thursday 26 February 2009 11:39:02 Herbert Xu wrote:
> Denis Romanenko <ash@sevsky.net> wrote:
> > I have high loaded router - about 1.2 Gbps
> >
> > after reboot on new kernel - 2.6.27.17 i have messages in dmesg
> >
> > WARNING: at kernel/softirq.c:136 local_bh_enable+0x36/0xab()
>
> So somebody disabled the IRQs on us, the question is who?
>
> Cheers,



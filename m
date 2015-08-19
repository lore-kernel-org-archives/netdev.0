From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 20/21] net: warn if drivers set tx_queue_len = 0
Date: Wed, 19 Aug 2015 13:31:59 -0700
Message-ID: <1440016319.6610.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439886649-24166-14-git-send-email-phil@nwl.cc>
	 <1439886649-24166-15-git-send-email-phil@nwl.cc>
	 <1439886649-24166-16-git-send-email-phil@nwl.cc>
	 <1439886649-24166-17-git-send-email-phil@nwl.cc>
	 <1439886649-24166-18-git-send-email-phil@nwl.cc>
	 <1439886649-24166-19-git-send-email-phil@nwl.cc>
	 <1439886649-24166-20-git-send-email-phil@nwl.cc>
	 <1439886649-24166-21-git-send-email-phil@nwl.cc>
	 <1439909248.6443.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150819183924.GA12537@orbit.nwl.cc> <20150819202104.GB12537@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, davem@davemloft.net
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33714 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbbHSUcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 16:32:01 -0400
Received: by padfo6 with SMTP id fo6so4345273pad.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 13:32:01 -0700 (PDT)
In-Reply-To: <20150819202104.GB12537@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-19 at 22:21 +0200, Phil Sutter wrote:
> On Wed, Aug 19, 2015 at 08:39:24PM +0200, Phil Sutter wrote:
> [...]
> > I'll start implementing the above immediately, but would appreciate to
> > hear your comments on it meanwhile. I wonder especially what makes the
> > difference between pfifo and pfifo_fast and why the latter can't be
> > selected explicitly by a user yet. Are there any good reasons for it
> > aside from it being the "default" and therefore selecting it can be done
> > by having tx_queue_len > 0 and removing the root qdisc?
> 
> Please ignore most of my questions regarding pfifo_fast here. I based my
> assumptions upon 'tc' utility of RHEL7, which is buggy in that it does
> not allow to add qdiscs which do not support extra options. Using
> mainline tc, pfifo_fast can be attached just like any other qdisc.
> 
> Sorry for the noise,

Yes, I was about to send you :

lpaa5:~# tc qd sh dev eth1
qdisc mq 0: root 
qdisc fq 0: parent :4 limit 10000p flow_limit 1000p buckets 1024 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 quantum 3028 initial_quantum 15140 
qdisc fq 0: parent :3 limit 10000p flow_limit 1000p buckets 1024 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 quantum 3028 initial_quantum 15140 
qdisc fq 0: parent :2 limit 10000p flow_limit 1000p buckets 1024 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 quantum 3028 initial_quantum 15140 
qdisc fq 0: parent :1 limit 10000p flow_limit 1000p buckets 1024 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 quantum 3028 initial_quantum 15140 
lpaa5:~# tc qd replace dev eth1 root pfifo_fast
lpaa5:~# tc -s -d qd sh dev eth1
qdisc pfifo_fast 8003: root refcnt 45 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 2662 bytes 22 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 

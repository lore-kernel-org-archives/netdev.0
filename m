From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 12:50:31 -0700
Message-ID: <1408045831.6804.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ECFDAB.5010701@intel.com>
	 <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:46556 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbaHNTud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 15:50:33 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so2126146pde.11
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 12:50:33 -0700 (PDT)
In-Reply-To: <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-14 at 11:46 -0700, Eric Dumazet wrote:

> I believe you answered your own question : prequeue mode does not work
> very well when one host has hundred of active TCP flows to one other.
> 
> In real life, applications do not use prequeue, because nobody wants one
> thread per flow.
> 
> Each socket has its own dst now route cache was removed, but if your
> netperf migrates cpu (and NUMA node), we do not detect the dst should be
> re-created onto a different NUMA node.
> 
> But really, I am not sure we want to care about prequeue, as modern
> applications uses epoll()/poll()/select() instead of blocking on
> recvmsg()

BTW it looks like you do not use RPS/RFS/RSS, so you have different cpus
doing the dst refcount increment and decrement.

With RFS, your workload just works fine.

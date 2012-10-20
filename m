From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] htb: improved accuracy at high rates
Date: Sat, 20 Oct 2012 09:26:34 +0200
Message-ID: <1350717994.13333.298.camel@edumazet-glaptop>
References: <1350685582-65334-1-git-send-email-j.vimal@gmail.com>
	 <5081E7A8.2080009@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vimalkumar <j.vimal@gmail.com>, davem@davemloft.net,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:60087 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653Ab2JTH1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 03:27:07 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so942512wib.1
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 00:27:05 -0700 (PDT)
In-Reply-To: <5081E7A8.2080009@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-19 at 16:52 -0700, Rick Jones wrote:

> Did it really take 20 concurrent netperf UDP_STREAM tests to get to 
> those rates?  And why UDP_STREAM rather than TCP_STREAM?
> 
> I couldn't recall if GSO did anything for UDP, so did some quick and 
> dirty tests flipping GSO on and off on a 3.2.0 kernel, and the service 
> demands didn't seem to change.  So, with 8000 bytes of user payload did 
> HTB actually see 8000ish byte packets, or did it actually see a series 
> of <= MTU sized IP datagram fragmentsOn 10/19/2012 03:26 PM, Vimalkumar wrote:

UFO is quite a virtual feature for the moment ;)

To my knowledge only one driver uses it (neterion/s2io.c)

So most probably HTB sees the fragments built by the stack before
queueing packets to the qdisc layer.

tcpdump can be used to check this.

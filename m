From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec smp scalability and cpu use fairness (softirqs)
Date: Tue, 20 Aug 2013 08:19:14 +0200
Message-ID: <20130820061914.GA26773@secunet.com>
References: <20130812160142.71737a95@vostro>
 <CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
 <20130813092312.2493354e@vostro>
 <20130813074614.GM25511@secunet.com>
 <20130813105757.39fb0ab8@vostro>
 <20130813104548.GB26773@secunet.com>
 <20130813143325.364b4bab@vostro>
 <20130813115652.GE26773@secunet.com>
 <20130813154102.35739102@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Collins <bsderandrew@gmail.com>, netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45250 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262Ab3HTGTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 02:19:16 -0400
Content-Disposition: inline
In-Reply-To: <20130813154102.35739102@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 03:41:02PM +0300, Timo Teras wrote:
> On Tue, 13 Aug 2013 13:56:52 +0200
> Steffen Klassert <steffen.klassert@secunet.com> wrote:
> 
> > 
> > I'll do some tests with current net-next on my own tomorrow and let
> > you know about the results.
> 
> Yes, I've got pcrypt there. Apparently I had some of the cpu bindings
> not right, so now it's looking a lot better. But it seems that
> ksoftirqd on one of the CPUs becomes first bottleneck. I'll try to
> figure out why.
> 
> Thanks on all the info so far, will continue experimenting here too.

Here are the promised test results:

I used my test boxes with two nodes (Intel Xeon X5550  @ 2.67GHz) and all
cores utilized (16 logical cores). I did iperf box to box IPsec tunnel
tests with the crypto algorithm:

pcrypt(authenc(hmac(sha1-ssse3),cbc(aes-asm)))

Throughput is at 1.70 Gbits/sec.

Same test without pcrypt, i.e. crypto algorithm:

authenc(hmac(sha1-ssse3),cbc(aes-asm))

Throughput is at 560 Mbits/sec.

Unfortunately I can't do forwarding tests, I have only two 10 Gbit NICs.
Would be nice if I could get forwarding test results from somewhere.

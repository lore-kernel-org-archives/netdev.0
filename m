From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec impact on performance
Date: Mon, 7 Dec 2015 09:40:50 +0100
Message-ID: <20151207084050.GH14008@secunet.com>
References: <20151201175953.GC21252@oracle.com>
 <20151202065305.GB14008@secunet.com>
 <20151202120538.GJ23178@oracle.com>
 <20151203084508.GD14008@secunet.com>
 <20151203113820.GX15262@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-crypto@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58896 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753208AbbLGIky (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 03:40:54 -0500
Content-Disposition: inline
In-Reply-To: <20151203113820.GX15262@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 03, 2015 at 06:38:20AM -0500, Sowmini Varadhan wrote:
> On (12/03/15 09:45), Steffen Klassert wrote:
> > pcrypt(echainiv(authenc(hmac(sha1-ssse3),cbc-aes-aesni)))
> > 
> > Result:
> > 
> > iperf -c 10.0.0.12 -t 60
> > ------------------------------------------------------------
> > Client connecting to 10.0.0.12, TCP port 5001
> > TCP window size: 45.0 KByte (default)
> > ------------------------------------------------------------
> > [  3] local 192.168.0.12 port 39380 connected with 10.0.0.12 port 5001
> > [ ID] Interval       Transfer     Bandwidth
> > [  3]  0.0-60.0 sec  32.8 GBytes  4.70 Gbits/sec
> > 
> > I provide more informatios as soon as the code is available.
> 
> that's pretty good compared to the baseline. 

This is GRO in combination with a pcrypt parallelized
crypto algorithm, without the parallelization GRO/GSO
does not help because crypto is the bottleneck then.

> I'd like to try out our patches, when they are ready.

I've pushed it to

https://git.kernel.org/cgit/linux/kernel/git/klassert/linux-stk.git/log/?h=net-next-ipsec-offload

It is just example code, nothing that I would show usually.
But you asked for it, so here is it :)

The GRO part seems to work well, the GSO part is just a hack at the 
moment.

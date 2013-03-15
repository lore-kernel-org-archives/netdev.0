From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Trying to implement secondary loopback
Date: Fri, 15 Mar 2013 16:15:28 +0100
Message-ID: <20130315151528.GA10503@order.stressinduktion.org>
References: <514326FF.6020205@hhi.fraunhofer.de> <CAFLxGvwvH_krBDJ2i-si1LX2SKbeeRmXGR+0ZbtEB2oKWt-GoA@mail.gmail.com> <51432B72.20408@hhi.fraunhofer.de> <CAFLxGvyCFHk=vhNYCY8obrVJR2rW9M7+J_ppyVpFq3AHAxjRjA@mail.gmail.com> <51432E13.5060003@hhi.fraunhofer.de> <CAFLxGvyDaaOtm1TrD-gfvhja_Uow8jtRbPyb2WcMscSLgo1umg@mail.gmail.com> <514331BC.4080802@hhi.fraunhofer.de> <CAFLxGvyzkoj_KtfH6=YK5LnpLW_N6sMdk7Hu=V=h5OK08oRE4Q@mail.gmail.com> <5143353C.3050107@hhi.fraunhofer.de> <51433934.3080405@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37452 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639Ab3COPPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 11:15:30 -0400
Content-Disposition: inline
In-Reply-To: <51433934.3080405@hhi.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 15, 2013 at 04:07:32PM +0100, Thomas Martitz wrote:
> Same result. I assumed the kernel treats lo in a special way for 
> localhost-connections and that it would be impossible to achieve the 
> same with a custom interface.
> 
> I did the following:
> 
> ifconfig lo down
> insmod ./mykmod.ko
> ifconfig eth2 up
> ifconfig eth2 127.0.0.1
> 
> At this point ifconfig prints the same information for eth2 that it had 
> printed for lo before (except for the LOOPBACK flag, but I can enable 
> that one as well by adding IFF_LOOPBACK to the interface flags in the 
> module). Yet my test application only works with lo, not eth2.

127.0.0.0/8 is guarded by the kernel, but there is a sysctl for relaxing the
checks, /proc/sys/net/ipv4/conf/route_localnet. You could give it a try.

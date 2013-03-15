From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: Trying to implement secondary loopback
Date: Fri, 15 Mar 2013 11:37:40 -0400
Message-ID: <20130315153740.GR8869@kvack.org>
References: <514326FF.6020205@hhi.fraunhofer.de> <CAFLxGvwvH_krBDJ2i-si1LX2SKbeeRmXGR+0ZbtEB2oKWt-GoA@mail.gmail.com> <51432B72.20408@hhi.fraunhofer.de> <CAFLxGvyCFHk=vhNYCY8obrVJR2rW9M7+J_ppyVpFq3AHAxjRjA@mail.gmail.com> <51432E13.5060003@hhi.fraunhofer.de> <CAFLxGvyDaaOtm1TrD-gfvhja_Uow8jtRbPyb2WcMscSLgo1umg@mail.gmail.com> <514331BC.4080802@hhi.fraunhofer.de> <CAFLxGvyzkoj_KtfH6=YK5LnpLW_N6sMdk7Hu=V=h5OK08oRE4Q@mail.gmail.com> <5143353C.3050107@hhi.fraunhofer.de> <51433934.3080405@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:60135 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091Ab3COQCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 12:02:43 -0400
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

Don't use loopback ip addresses; it makes no sense to do so.  I've worked  
on a couple opf nic implementations on FPGAs for a while now (a gige 
implementation that works, and now a 10G nic), and it's easy enough to 
develop it as a regular ethernet driver.  You can write test programs that 
use raw sockets to send/receive packets over the ethernet device, or use 
pktgen to send packets.  You don't even need to configure an ip address for 
testing with raw packets.  Testing with IP is a lot harder during early 
bring-up of your hardware as it requires everything to work (that is, you 
need ARP to work successfully before IP can work).  Just stick to simple 
packet injection initially, and don't confuse yourself by thinking about 
the loopback device.

		-ben
-- 
"Thought is the essence of where you are now."

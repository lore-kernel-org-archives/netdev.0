From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] ipv4: accept u8 in IP_TOS ancillary data
Date: Tue, 13 Sep 2016 09:07:32 +0200
Message-ID: <20160913090732.069417a2@redhat.com>
References: <1473310376.15733.26.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160908111519.62af94bf@redhat.com>
        <1473341474.15733.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Francesco Fusco <fusco@ntop.org>,
        Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <maze@google.com>,
        brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51334 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751547AbcIMHHh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 03:07:37 -0400
In-Reply-To: <1473341474.15733.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 Sep 2016 06:31:14 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2016-09-08 at 11:15 +0200, Jesper Dangaard Brouer wrote:
> > On Wed, 07 Sep 2016 21:52:56 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >   
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > In commit f02db315b8d8 ("ipv4: IP_TOS and IP_TTL can be specified as
> > > ancillary data") Francesco added IP_TOS values specified as integer.
> > > 
> > > However, kernel sends to userspace (at recvmsg() time) an IP_TOS value
> > > in a single byte, when IP_RECVTOS is set on the socket.
> > > 
> > > It can be very useful to reflect all ancillary options as given by the
> > > kernel in a subsequent sendmsg(), instead of aborting the sendmsg() with
> > > EINVAL after Francesco patch.
> > > 
> > > So this patch extends IP_TOS ancillary to accept an u8, so that an UDP
> > > server can simply reuse same ancillary block without having to mangle
> > > it.
> > > 
> > > Jesper can then augment
> > > https://github.com/netoptimizer/network-testing/blob/master/src/udp_example02.c
> > > to add TOS reflection ;)  
> > 
> > This is actually your old program ;-)
> > Do I need to change anything, as I'm just bouncing the packet back with sendmsg() ?  
> 
> I guess you want to add an option and if this option is requested by the
> user, add :
> 
> 	setsockopt(fd, SOL_IP, IP_PKTINFO, &on, sizeof(on));
> +	if (tos_reflect)
> +		setsockopt(fd, SOL_IP, IP_RECVTOS, &on, sizeof(on));
> 
> before the loop doing the recvmsg()/sendmsg() calls.

Hi Eric,

I've implemented what you suggested:
 https://github.com/netoptimizer/network-testing/commit/0758ad77a96ecb1

Now QA can use this tool to verify the kernel commit ;-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

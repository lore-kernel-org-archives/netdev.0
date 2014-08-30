From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Sat, 30 Aug 2014 12:23:52 +0200
Message-ID: <20140830122352.1177be1e@redhat.com>
References: <1409142672.26515.24.camel@localhost>
	<20140827.134510.2172564669938048576.davem@davemloft.net>
	<1409190174.27664.10.camel@localhost>
	<20140829.202210.1424256004723217664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, john.r.fastabend@intel.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbaH3KYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Aug 2014 06:24:07 -0400
In-Reply-To: <20140829.202210.1424256004723217664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Aug 2014 20:22:10 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 28 Aug 2014 03:42:54 +0200
> 
> > I wonder if we still might need a separate call for tx_flush, e.g. for
> > af_packet if one wants to allow user space control of batching, MSG_MORE
> > with tx hangcheck (also in case user space has control over it) or
> > implement TCP_CORK alike option in af_packet.
> 
> I disagree with allowing the user to hold a device TX queue hostage
> across system calls, therefore the user should provide the entire
> batch in such a case.

I believe we should only do tailptr batching/delaying, when a batch of
packets is readily available.  I don't like the concept of speculative
delaying the tailptr update, in hope a new packet will arrive shortly.

We still might need a call for tx_flush, if some error case occurs while
we are looping over our batch of packets.  Most of these TX error
situation should be hopefully be detected in the driver, and cause the
driver to write the tailptr before returning.  Like in commit
2367a17390 ("ixgbe: flush when in xmit_more mode and under descriptor
pressure").

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

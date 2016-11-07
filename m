From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 0/3] qdisc and tx_queue_len cleanups for
 IFF_NO_QUEUE devices
Date: Mon, 7 Nov 2016 21:11:17 +0100
Message-ID: <20161107211117.7e90c089@redhat.com>
References: <20161103135534.28737.37657.stgit@firesoul>
        <20161107.131344.1991435301554344262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc, robert@herjulf.se,
        jhs@mojatatu.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60340 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750905AbcKGULX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Nov 2016 15:11:23 -0500
In-Reply-To: <20161107.131344.1991435301554344262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Nov 2016 13:13:44 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Thu, 03 Nov 2016 14:55:56 +0100
> 
> > This patchset is a cleanup for IFF_NO_QUEUE devices.  It will
> > hopefully help userspace get a more consistent behavior when attaching
> > qdisc to such virtual devices.  
> 
> I'm still thinking about this.
> 
> My reservation about this is basically since the one known offender in
> userspace acknowledged that what it was doing wrong, and fixed it
> quickly already, I see no reason to explicitly accomodate this.

The situation I worry about is that a sysadm cannot manually apply a tc
qdisc on a Docker container's veth without getting bitten.  Docker will
forever run a "loophole-script" to accommodate older kernels, and yes
the shiny management scripts will get fixed, but how should a mortal
sysadm know (to change tx_queue_len before applying a qdisc).

Besides the it was only fixed in OpenShift, which inherited the "bug"
from Docker.  Thus, it is per-say not fixed in Docker or other projects
that (like OpenShift) uses components from Docker.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

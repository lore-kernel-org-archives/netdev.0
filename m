From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] i40e/i40evf: Limit TSO to 7 descriptors for payload
 instead of 8 per packet
Date: Wed, 30 Mar 2016 13:15:04 -0700
Message-ID: <1459368904.6473.207.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160330064213.12927.46852.stgit@localhost.localdomain>
	 <20160330170011.GB27540@oracle.com>
	 <CAKgT0UdTgaeamyLetGPK0mqMNS-80BTc8t-WdSGJuuLDfz4JOg@mail.gmail.com>
	 <20160330172001.GD27540@oracle.com>
	 <CAKgT0Ufb-_X-DD2jYkVJQwLZ-JBfWD2Biuhi6YaxWBeNy9K2fQ@mail.gmail.com>
	 <20160330124135.000054c6@unknown> <20160330200959.GI27540@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33536 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401AbcC3UPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 16:15:07 -0400
Received: by mail-pa0-f54.google.com with SMTP id zm5so48629862pac.0
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 13:15:06 -0700 (PDT)
In-Reply-To: <20160330200959.GI27540@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-30 at 16:09 -0400, Sowmini Varadhan wrote:
> On (03/30/16 12:41), Jesse Brandeburg wrote:
> > This gets "Even Uglier", I've turned off all offloads at my receiver,
> > enabled calling skb_linearize on *all* frames, which works fine for
> > scp, but the receiver shows > MSS sized frames on the wire for
> > rds-stress traffic.
> 
> fwiw, I was not able to reproduce this tx issue with iperf/netperf
> etc either (I tried various perumtations of bidir, req-resp etc). One
> difference between the rds-stress invocation and the other callers
> is that this comes down via tcp_sendpage(), I dont know if there
> is something in the sendpage path that i40e does not anticipate. 

You might try netperf -t TCP_SENDFILE -- -m 150

to let netperf use sendfile() on small frags.

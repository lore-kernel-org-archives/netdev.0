From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [net PATCH] i40e/i40evf: Limit TSO to 7 descriptors for payload
 instead of 8 per packet
Date: Wed, 30 Mar 2016 16:09:59 -0400
Message-ID: <20160330200959.GI27540@oracle.com>
References: <20160330064213.12927.46852.stgit@localhost.localdomain>
 <20160330170011.GB27540@oracle.com>
 <CAKgT0UdTgaeamyLetGPK0mqMNS-80BTc8t-WdSGJuuLDfz4JOg@mail.gmail.com>
 <20160330172001.GD27540@oracle.com>
 <CAKgT0Ufb-_X-DD2jYkVJQwLZ-JBfWD2Biuhi6YaxWBeNy9K2fQ@mail.gmail.com>
 <20160330124135.000054c6@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44938 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755761AbcC3UKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 16:10:14 -0400
Content-Disposition: inline
In-Reply-To: <20160330124135.000054c6@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/30/16 12:41), Jesse Brandeburg wrote:
> This gets "Even Uglier", I've turned off all offloads at my receiver,
> enabled calling skb_linearize on *all* frames, which works fine for
> scp, but the receiver shows > MSS sized frames on the wire for
> rds-stress traffic.

fwiw, I was not able to reproduce this tx issue with iperf/netperf
etc either (I tried various perumtations of bidir, req-resp etc). One
difference between the rds-stress invocation and the other callers
is that this comes down via tcp_sendpage(), I dont know if there
is something in the sendpage path that i40e does not anticipate. 

Other drivers (ixgbe etc) work fine, so my hunch would be that this
is specific to i40e (and not a skb_linearize bug) but I could be
wrong.

--Sowmini

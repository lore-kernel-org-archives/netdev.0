From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] tun: use per cpu variables for stats accounting
Date: Fri, 15 Apr 2016 14:30:28 +0200
Message-ID: <1460723428.7410.7.camel@redhat.com>
References: <597a2e5c2f664d48d3e4aac2f7d43e61940d4037.1460537477.git.pabeni@redhat.com>
	 <20160414.225617.2128747969495613941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, hannes@stressinduktion.org,
	ebiederm@xmission.com, gkurz@linux.vnet.ibm.com,
	jasowang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56177 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750716AbcDOMac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2016 08:30:32 -0400
In-Reply-To: <20160414.225617.2128747969495613941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-14 at 22:56 -0400, David Miller wrote:
> From: Paolo Abeni <pabeni@redhat.com>
> Date: Wed, 13 Apr 2016 10:52:20 +0200
> 
> > Currently the tun device accounting uses dev->stats without applying any
> > kind of protection, regardless that accounting happens in preemptible
> > process context.
> > This patch move the tun stats to a per cpu data structure, and protect
> > the updates with  u64_stats_update_begin()/u64_stats_update_end() or
> > this_cpu_inc according to the stat type. The per cpu stats are
> > aggregated by the newly added ndo_get_stats64 ops.
> > 
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> Ok this seems reasonable, applied, thanks.
> 
> I guess most applications use tuntap by having two threads, one
> for transmit and one for receive processing?

Probably. I guess that an user space application can leverage multiple
transmit threads to improve the throughput.

Paolo

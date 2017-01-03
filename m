From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] drop_monitor: consider inserted data in genlmsg_end
Date: Tue, 3 Jan 2017 11:04:43 -0500
Message-ID: <20170103160443.GC11735@hmsreliant.think-freely.org>
References: <20170103003910.8984-1-wr0112358@gmail.com>
 <20170103.095419.261470619535526723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wr0112358@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60012 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935355AbdACQFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 11:05:40 -0500
Content-Disposition: inline
In-Reply-To: <20170103.095419.261470619535526723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2017 at 09:54:19AM -0500, David Miller wrote:
> From: Reiter Wolfgang <wr0112358@gmail.com>
> Date: Tue,  3 Jan 2017 01:39:10 +0100
> 
> > Final nlmsg_len field update must reflect inserted net_dm_drop_point
> > data.
> > 
> > This patch depends on previous patch:
> > "drop_monitor: add missing call to genlmsg_end"
> > 
> > Signed-off-by: Reiter Wolfgang <wr0112358@gmail.com>
> 
> I don't understand why the current code doesn't work properly.
> 
> All over the tree, the pattern is:
> 
> 	x = genlmsg_put(skb, ...);
> 	...
> 	genlmsg_end(skb, x);
> 
> And that is exactly what the code is doing right now.
> 

Because reset_per_cpu_data should close the use of of the established skb
that was being written to.  Without this patch we add the END tlv to the skb
that is just getting started for use in the drop monitor, rather than for the
skb that is getting returned for use in sending up to user space listeners.

Or am I missing something?

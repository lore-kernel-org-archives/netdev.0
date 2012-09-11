From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/2] netprio_cgroup: Optimize the priomap copy loop
 slightly
Date: Tue, 11 Sep 2012 11:33:09 -0400
Message-ID: <20120911153309.GA25666@hmsreliant.think-freely.org>
References: <20120911112231.13852.61794.stgit@srivatsabhat.in.ibm.com>
 <20120911112237.13852.1095.stgit@srivatsabhat.in.ibm.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6FE9@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	davem@davemloft.net, john.r.fastabend@intel.com,
	gaofeng@cn.fujitsu.com, eric.dumazet@gmail.com,
	mark.d.rustad@intel.com, lizefan@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59326 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab2IKPdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 11:33:42 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE9@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 11, 2012 at 12:42:23PM +0100, David Laight wrote:
> > -	for (i = 0;
> > -	     old_priomap && (i < old_priomap->priomap_len);
> > -	     i++)
> > -		new_priomap->priomap[i] = old_priomap->priomap[i];
> > +	if (old_priomap) {
> > +		old_len = old_priomap->priomap_len;
> > +
> > +		for (i = 0; i < old_len; i++)
> > +			new_priomap->priomap[i] = old_priomap->priomap[i];
> > +	}
> 
> Or:
> 	memcpy(new_priomap->priomap, old_priomap->priomap,
> 		old_priomap->priomap_len * sizeof old_priomap->priomap[0]);
> 
> 	David
> 
Yes, the memcpy would be better here.
Neil

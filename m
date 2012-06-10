From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: mlx4_core: Modify driver initialization flow to accommodate
 SRIOV for Ethernet
Date: Sun, 10 Jun 2012 02:03:37 +0100
Message-ID: <1339290217.21665.164.camel@deadeye.wl.decadent.org.uk>
References: <20120609090918.GB877@elgon.mountain>
	 <201206091429.17171.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>, <netdev@vger.kernel.org>,
	<dotanb@mellanox.co.il>, Or Gerlitz <ogerlitz@mellanox.com>
To: Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8747 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753923Ab2FJBDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 21:03:42 -0400
In-Reply-To: <201206091429.17171.jackm@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-09 at 14:29 +0300, Jack Morgenstein wrote:
> On Saturday 09 June 2012 12:09, Dan Carpenter wrote:
> >    423          /*fail if the hca has an unknown capability */
> >    424          if ((hca_param.global_caps | HCA_GLOBAL_CAP_MASK) !=
> >    425              HCA_GLOBAL_CAP_MASK) {
> >    426                  mlx4_err(dev, "Unknown hca global capabilities\n");
> >    427                  return -ENOSYS;
> >    428          }
> > 
> > The test sort of makes sense but HCA_GLOBAL_CAP_MASK is zero so we could
> > as well say:
> > 
> >         if (hca_param.global_caps) { ...
> > 
> The parameter global_caps is to guarantee that the guest OS is capable
> of supporting the driver which is running on the master (hypervisor).
> 
> If a new feature impacts the guests, we will define a bit in the
> global_caps bitmask and the master driver will set this bit and
> the global_caps bitmask with the newly set bit will be passed
> to the slaves.
> 
> The HCA_GLOBAL_CAP_MASK on the slave OS represents the set
> of such features which the slave knows how to support.
> If a new feature appears which is not set in the slave's
> HCA_GLOBAL_CAP_MASK, this test detects the discrepancy and
> the slave driver aborts.
[...]

It would be more idiomatic to write the condition as:

	if (hca_param.global_caps & ~(u64)HCA_GLOBAL_CAP_MASK)

(although that cast probably belongs in the definition of
HCA_GLOBAL_CAP_MASK).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next v2 0/9] Introduce devlink interface and first
 drivers to use it
Date: Thu, 25 Feb 2016 16:50:48 -0500
Message-ID: <20160225215046.GG33942@gospo.home.greyhouse.net>
References: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
 <20160225.151247.479900417232368503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, netdev@vger.kernel.org, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33253 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbcBYVuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:50:52 -0500
Received: by mail-qg0-f47.google.com with SMTP id b35so51323459qge.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 13:50:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160225.151247.479900417232368503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2016 at 03:12:47PM -0500, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Tue, 23 Feb 2016 16:51:25 +0100
> 
> > There a is need for some userspace API that would allow to expose things
> > that are not directly related to any device class like net_device of
> > ib_device, but rather chip-wide/switch-ASIC-wide stuff.
> > 
> > Use cases:
> > 1) get/set of port type (Ethernet/InfiniBand)
> > 2) setting up port splitters - split port into multiple ones and squash again,
> >    enables usage of splitter cable
> > 3) setting up shared buffers - shared among multiple ports within
> >    one chip (work in progress)
> > 4) configuration of switch wide properties - resources division etc - This will
> >    allow to pass configuration that is unacceptable to be passed as
> >    a module option.
> > 
> > First patch of this set introduces a new generic Netlink based interface,
> > called "devlink". It is similar to nl80211 model and it is heavily
> > influenced by it, including the API definition. The devlink introduction patch
> > implements use cases 1) and 2). Other 2 are in development atm and will
> > be addressed by follow-ups.
> > 
> > It is very convenient for drivers to use devlink, as you can see in other
> > patches in this set.
> > 
> > Counterpart for devlink is userspace tool for now called "dl". Command line
> > interface and outputs are derived from "ip" tool so it should be easy
> > for users to get used to it.
> 
> I am very close to applying this series as-is.
> 
> The clincher for me is that there is precendence in the nl80211 stuff,
> so obviously whatever userland infrastructure sits on top of that has
> found a way to deal whatever perceived shortcomings devlink has.
> 
> If all that people can come up with is "device names! omg UDEV!" and
> "multiple tools are hard to use!"  That's awesome, because it means
> nobody has any real substantial objection to this facility. :-)

Generally speaking I had no issue with the patch after being *ahem*
corrected to realize that the set operations only applied to the devlink
devices not specifically to netdevs.

I find this interface useful for some other items we have discussed in
the past (resource limits for routes, etc), so I'm happy to see some
interface for general chip maintenance included.

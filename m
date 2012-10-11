From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: unresponsive vlan on top of bond with fail_over_mac=active
Date: Thu, 11 Oct 2012 12:37:58 +0200
Message-ID: <20121011103757.GA13873@unicorn.suse.cz>
References: <20121010231122.GB28935@unicorn.suse.cz>
 <8588.1349926471@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51031 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801Ab2JKKh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2012 06:37:59 -0400
Content-Disposition: inline
In-Reply-To: <8588.1349926471@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 10, 2012 at 08:34:31PM -0700, Jay Vosburgh wrote:
> Michal Kubecek <mkubecek@suse.cz> wrote:
> 	What network device are they using that requires fail_over_mac
> to be set to active?

I would have to ask for exact configuration, all I know for sure is that
the problem was reported for s390x (S390-64) architecture. I reproduced
it with VMware Workstation virtual devices which emulate Intel e1000.

> 	I tested some of this out earlier this year, and I don't recall
> having problems (although I'm not sure I did this exact test).  The
> dev_uc_add() logic (in __dev_set_rx_mode) would put the underlying
> device into promiscuous mode if the hardware didn't support multiple
> unicast MAC addresses. dev_uc_add() was invoked by vlan_sync_address(),
> which is called by the vlan NETDEV_CHANGEADDR notifier callback.

Yes, this part works fine, I checked uc list with live crash session.
But as bonding driver doesn't set its ndo_set_rx_mode method, the
iformation about second MAC address doesn't propagate down to the
slaves.

> 	Bonding does propagate promisc to its slaves, but (as you point
> out) not the uc lists; is the hardware in question something that
> supports multiple unicast addresses (IFF_UNICAST_FLT)?  The device I
> tested with does not support IFF_UNICAST_FLT, and (as I recall) would
> end up in promisc mode.

My tests were done with (emulated) e1000 which supports unicast
filtering (up to 14 addresses, according to what I've seen in the
driver). I'm not sure about the devices on s390x.

                                                      Michal Kubecek

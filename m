From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [patch net-next] bonding: allow to add vlans on top of empty bond
Date: Wed, 2 Jul 2014 11:05:17 +0200
Message-ID: <20140702090517.GA5440@unicorn.suse.cz>
References: <1403878392-10004-1-git-send-email-jiri@resnulli.us>
 <CAG-2HqUKGoG5ZX26aYwv3quUU5RPtn5J1g6i4YzkXUc10u4c0w@mail.gmail.com>
 <26863.1403885330@localhost.localdomain>
 <20140702084652.GA3015@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Tom Gundersen <teg@jklm.no>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, vfalico@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36274 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbaGBJFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 05:05:19 -0400
Content-Disposition: inline
In-Reply-To: <20140702084652.GA3015@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 02, 2014 at 10:46:52AM +0200, Jiri Pirko wrote:
> Fri, Jun 27, 2014 at 06:08:50PM CEST, jay.vosburgh@canonical.com wrote:
> >
> >        if (!bond_has_slaves(bond)) {
> >                bond_set_carrier(bond);
> >                eth_hw_addr_random(bond_dev);
> >
> >                if (vlan_uses_dev(bond_dev)) {
> >                        pr_warn("%s: Warning: clearing HW address of %s while it still has VLANs\n",
> >                                bond_dev->name, bond_dev->name);
> >                        pr_warn("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs\n",
> >                                bond_dev->name);
> >                }
> >        }
> >
> >	This warning may not be useful any longer, since the MAC should
> >update correctly without user action when re-adding the first slave.
> 
> I just checked. The vlan dev holds its addr. So when new slave is added,
> bond addr is changed to it, but vlan addr remains the same. So the
> second warning still stands.

Is it a problem? Since we have proper uc_list propagation, vlan should
work even if its address doesn't match the bond.

                                                        Michal Kubecek

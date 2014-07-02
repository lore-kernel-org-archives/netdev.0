From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] bonding: allow to add vlans on top of empty bond
Date: Wed, 2 Jul 2014 11:13:16 +0200
Message-ID: <20140702091316.GB3015@minipsycho.orion>
References: <1403878392-10004-1-git-send-email-jiri@resnulli.us>
 <CAG-2HqUKGoG5ZX26aYwv3quUU5RPtn5J1g6i4YzkXUc10u4c0w@mail.gmail.com>
 <26863.1403885330@localhost.localdomain>
 <20140702084652.GA3015@minipsycho.orion>
 <20140702090517.GA5440@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Tom Gundersen <teg@jklm.no>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, vfalico@gmail.com,
	andy@greyhouse.net
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33861 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbaGBJNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 05:13:25 -0400
Received: by mail-wi0-f178.google.com with SMTP id n15so73440wiw.11
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 02:13:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140702090517.GA5440@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jul 02, 2014 at 11:05:17AM CEST, mkubecek@suse.cz wrote:
>On Wed, Jul 02, 2014 at 10:46:52AM +0200, Jiri Pirko wrote:
>> Fri, Jun 27, 2014 at 06:08:50PM CEST, jay.vosburgh@canonical.com wrote:
>> >
>> >        if (!bond_has_slaves(bond)) {
>> >                bond_set_carrier(bond);
>> >                eth_hw_addr_random(bond_dev);
>> >
>> >                if (vlan_uses_dev(bond_dev)) {
>> >                        pr_warn("%s: Warning: clearing HW address of %s while it still has VLANs\n",
>> >                                bond_dev->name, bond_dev->name);
>> >                        pr_warn("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs\n",
>> >                                bond_dev->name);
>> >                }
>> >        }
>> >
>> >	This warning may not be useful any longer, since the MAC should
>> >update correctly without user action when re-adding the first slave.
>> 
>> I just checked. The vlan dev holds its addr. So when new slave is added,
>> bond addr is changed to it, but vlan addr remains the same. So the
>> second warning still stands.
>
>Is it a problem? Since we have proper uc_list propagation, vlan should
>work even if its address doesn't match the bond.

You are right, vlan_sync_address() should take care of it.

I'll send a patch removing these 2 warnings. Thanks.

>
>                                                        Michal Kubecek
>

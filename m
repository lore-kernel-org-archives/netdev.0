From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] be2net: fix MAC addr setting on privileged BE3
 VFs
Date: Sun, 15 Jan 2017 23:50:10 -0500 (EST)
Message-ID: <20170115.235010.808547479902506292.davem@davemloft.net>
References: <20170113213829.22722-1-cera@cera.cz>
        <20170113213829.22722-3-cera@cera.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com
To: cera@cera.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58826 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751060AbdAPEuR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 23:50:17 -0500
In-Reply-To: <20170113213829.22722-3-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <cera@cera.cz>
Date: Fri, 13 Jan 2017 22:38:29 +0100

> During interface opening MAC address stored in netdev->dev_addr is
> programmed in the HW with exception of BE3 VFs where the initial
> MAC is programmed by parent PF. This is OK when MAC address is not
> changed when an interfaces is down. In this case the requested MAC is
> stored to netdev->dev_addr and later is stored into HW during opening.
> But this is not done for all BE3 VFs so the NIC HW does not know
> anything about this change and all traffic is filtered.
> 
> This is the case of bonding if fail_over_mac == 0 where the MACs of
> the slaves are changed while they are down.
> 
> The be2net behavior is too restrictive because if a BE3 VF has
> the FILTMGMT privilege then it is able to modify its MAC without
> any restriction.
> 
> To solve the described problem the driver should take care about these
> privileged BE3 VFs so the MAC is programmed during opening. And by
> contrast unpriviled BE3 VFs should not be allowed to change its MAC
> in any case.
> 
> Cc: Sathya Perla <sathya.perla@broadcom.com>
> Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Cc: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Ivan Vecera <cera@cera.cz>
Applied.

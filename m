From: David Miller <davem@davemloft.net>
Subject: Re: [net] i40e: Fix a sleep-in-atomic bug
Date: Wed, 14 Jun 2017 23:46:01 -0400 (EDT)
Message-ID: <20170614.234601.1396528844501606393.davem@davemloft.net>
References: <20170614233531.40509-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baijiaju1990@163.com, netdev@vger.kernel.org, nhorman@redhat.com,
        sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752105AbdFODqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 23:46:03 -0400
In-Reply-To: <20170614233531.40509-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 14 Jun 2017 16:35:31 -0700

> From: Jia-Ju Bai <baijiaju1990@163.com>
> 
> The driver may sleep under a spin lock, and the function call path is:
> i40e_ndo_set_vf_port_vlan (acquire the lock by spin_lock_bh)
>   i40e_vsi_remove_pvid
>     i40e_vlan_stripping_disable
>       i40e_aq_update_vsi_params
>         i40e_asq_send_command
>           mutex_lock --> may sleep
> 
> To fixed it, the spin lock is released before "i40e_vsi_remove_pvid", and
> the lock is acquired again after this function.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.

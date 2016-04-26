From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvtap: check minor when unregistering
Date: Tue, 26 Apr 2016 15:19:19 -0400 (EDT)
Message-ID: <20160426.151919.1718268588062036257.davem@davemloft.net>
References: <1461449071-7499-1-git-send-email-fruggeri@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: fruggeri@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbcDZTT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 15:19:26 -0400
In-Reply-To: <1461449071-7499-1-git-send-email-fruggeri@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Ruggeri <fruggeri@arista.com>
Date: Sat, 23 Apr 2016 15:04:31 -0700

> macvtap_device_event(NETDEV_UNREGISTER) should check vlan->minor to
> determine if it is being invoked in the context of a macvtap_newlink
> that failed, for example in this code sequence:
> 
> macvtap_newlink
>   macvlan_common_newlink
>     register_netdevice
>       call_netdevice_notifiers(NETDEV_REGISTER, dev)
>         macvtap_device_event(NETDEV_REGISTER)
>           <fail here, vlan->minor = 0>
>       rollback_registered(dev);
>         rollback_registered_many
>           call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>             macvtap_device_event(NETDEV_UNREGISTER)
>               <nothing to clean up here>
> 
> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>

Applied.

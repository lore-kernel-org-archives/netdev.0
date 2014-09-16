From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] sfc: fix addr_list_lock spinlock use before init
Date: Tue, 16 Sep 2014 17:20:00 +0200
Message-ID: <54185520.5090507@redhat.com>
References: <1410785727-659-1-git-send-email-nikolay@redhat.com> <alpine.LFD.2.03.1409161540490.25290@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Ben Hutchings <ben@decadent.org.uk>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753277AbaIPPUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 11:20:18 -0400
In-Reply-To: <alpine.LFD.2.03.1409161540490.25290@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/09/14 17:05, Edward Cree wrote:
> On Mon, 15 Sep 2014, Nikolay Aleksandrov wrote:
>> When the module is initializing the ports it may call a function that
>> uses addr_list_lock before register_netdevice() has been called for that
>> port i.e. addr_list_lock is still uninitialized. The function in
>> question is efx_farch_filter_sync_rx_mode(), now it looks pointless to call
>> it before the port has been registered so alter the reconfigure_mac
>> callbacks to check if the port has been registered using the existing
>> efx_dev_registered() macro.
>
> Weak NAK as this should really be done in efx_farch_filter_sync_rx_mode()
Indeed, seems like the best place.

> rather than its callers.  In fact it seems our out-of-tree driver has done
> this for a while but we forgot to upstream it, though curiously we did
> upstream the corresponding fix for EF10.
Ah yes, I saw it in the ef10 code. I should've checked with the out-of-tree 
driver first, will note for future submissions :-)

> Will follow up with a patch after sanity testing it.
>
> --
> -Edward Cree

Okay, fair enough.

Thanks,
  Nik

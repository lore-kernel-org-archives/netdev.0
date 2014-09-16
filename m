From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net] sfc: fix addr_list_lock spinlock use before init
Date: Tue, 16 Sep 2014 16:05:56 +0100
Message-ID: <alpine.LFD.2.03.1409161540490.25290@solarflare.com>
References: <1410785727-659-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Shradha Shah <sshah@solarflare.com>,
	"Solarflare linux maintainers" <linux-net-drivers@solarflare.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:24991 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753806AbaIPPON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 11:14:13 -0400
In-Reply-To: <1410785727-659-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Sep 2014, Nikolay Aleksandrov wrote:
> When the module is initializing the ports it may call a function that
> uses addr_list_lock before register_netdevice() has been called for that
> port i.e. addr_list_lock is still uninitialized. The function in
> question is efx_farch_filter_sync_rx_mode(), now it looks pointless to call
> it before the port has been registered so alter the reconfigure_mac
> callbacks to check if the port has been registered using the existing
> efx_dev_registered() macro.

Weak NAK as this should really be done in efx_farch_filter_sync_rx_mode() 
rather than its callers.  In fact it seems our out-of-tree driver has done 
this for a while but we forgot to upstream it, though curiously we did 
upstream the corresponding fix for EF10.
Will follow up with a patch after sanity testing it.

--
-Edward Cree

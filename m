From: David Miller <davem@davemloft.net>
Subject: Re: [V2 1/7] Drivers: hv: vmbus: define the new offer type for
 Hyper-V socket (hvsock)
Date: Wed, 15 Jul 2015 21:13:06 -0700 (PDT)
Message-ID: <20150715.211306.576715827080894506.davem@davemloft.net>
References: <1436867883-17692-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com
To: decui@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbbGPENH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 00:13:07 -0400
In-Reply-To: <1436867883-17692-1-git-send-email-decui@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dexuan Cui <decui@microsoft.com>
Date: Tue, 14 Jul 2015 02:58:03 -0700

> A helper function is also added.
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>
> ---
>  include/linux/hyperv.h | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
> index 30d3a1f..aa21814 100644
> --- a/include/linux/hyperv.h
> +++ b/include/linux/hyperv.h
> @@ -236,6 +236,7 @@ struct vmbus_channel_offer {
>  #define VMBUS_CHANNEL_LOOPBACK_OFFER			0x100
>  #define VMBUS_CHANNEL_PARENT_OFFER			0x200
>  #define VMBUS_CHANNEL_REQUEST_MONITORED_NOTIFICATION	0x400
> +#define VMBUS_CHANNEL_TLNPI_PROVIDER_OFFER		0x2000
>  
>  struct vmpacket_descriptor {
>  	u16 type;
> @@ -758,6 +759,12 @@ struct vmbus_channel {
>  	struct list_head percpu_list;
>  };
>  
> +static inline bool is_hvsock_channel(const struct vmbus_channel *c)
> +{
> +	return !!(c->offermsg.offer.chn_flags &
> +		VMBUS_CHANNEL_TLNPI_PROVIDER_OFFER);
> +}
> +

This is not indented properly, plus it makes no sense to add a flag before
anyone even sets the flag.

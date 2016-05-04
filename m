From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] vrf: add exit function and allow module unload
Date: Wed, 04 May 2016 12:23:42 +0200
Message-ID: <1462357422.1666076.597731009.4C5E1305@webmail.messagingengine.com>
References: <1462357236-6297-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, dsa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:37603 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751383AbcEDKXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 06:23:44 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 0887220A92
	for <netdev@vger.kernel.org>; Wed,  4 May 2016 06:23:42 -0400 (EDT)
In-Reply-To: <1462357236-6297-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jiri,

On Wed, May 4, 2016, at 12:20, Jiri Pirko wrote:
>  drivers/net/vrf.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index 8a8f1e5..b217c2d 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -839,7 +839,14 @@ error:
>  	return rc;
>  }
>  
> +static void __exit vrf_exit_module(void)
> +{
> +       rtnl_link_unregister(&vrf_link_ops);
> +       unregister_netdevice_notifier(&vrf_notifier_block);
> +}
> +
>  module_init(vrf_init_module);
> +module_exit(vrf_exit_module);

The dst_entries created by vrf don't carry a reference to THIS_MODULE
but have a code dependency to the vrf module (e.g. via
vrf_output/vrf_output6) that gets published. This is exactly the same
why ipv6 cannot be unloaded.

Bye,
Hannes

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH/RFC net-next 4/9] nfp: extend flower add flow offload
Date: Tue, 27 Jun 2017 23:13:30 -0700
Message-ID: <20170627231330.43a3f14a@cakuba.netronome.com>
References: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
        <1498605709-22574-5-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35120 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751696AbdF1GNd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 02:13:33 -0400
Received: by mail-pf0-f181.google.com with SMTP id c73so28079742pfk.2
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 23:13:33 -0700 (PDT)
In-Reply-To: <1498605709-22574-5-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jun 2017 01:21:44 +0200, Simon Horman wrote:
> diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
> index 9127c28ea9c3..8ad72f57493d 100644
> --- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
> +++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
> @@ -45,6 +45,145 @@
>  #include "../nfp_net.h"
>  #include "../nfp_port.h"
>  
> +static bool nfp_flower_check_lower_than_mac(struct tc_cls_flower_offload *f)
> +{
> +	return dissector_uses_key(f->dissector,
> +				  FLOW_DISSECTOR_KEY_IPV4_ADDRS) ||
> +		dissector_uses_key(f->dissector,
> +				   FLOW_DISSECTOR_KEY_IPV6_ADDRS) ||
> +		dissector_uses_key(f->dissector,
> +				   FLOW_DISSECTOR_KEY_PORTS) ||
> +		dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ICMP);
> +}

Nit: should this be named higher than mac?

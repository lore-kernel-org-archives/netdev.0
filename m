From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 8/9] i40e/i40evf: Add support for GSO partial with
 UDP_TUNNEL_CSUM and GRE_CSUM
Date: Wed, 23 Mar 2016 12:35:50 -0700
Message-ID: <CAEh+42jxjkhoTeC0GK91pmX6XUpnMAxnA-pRhbG0kkQFfa2WXQ@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain> <20160318232528.14955.87859.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46673 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755713AbcCWTgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 15:36:08 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id A8AD32041E
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 19:36:06 +0000 (UTC)
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7740220398
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 19:36:05 +0000 (UTC)
Received: by mail-qg0-f50.google.com with SMTP id j35so20928869qge.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 12:36:05 -0700 (PDT)
In-Reply-To: <20160318232528.14955.87859.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 4:25 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 39b0009253c2..ac3964a9f5c0 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -9074,7 +9075,12 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
>         if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
>                 netdev->features |= NETIF_F_NTUPLE;
>         if (pf->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE)
> -               netdev->features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
> +               netdev->features = NETIF_F_GSO_UDP_TUNNEL_CSUM;

Looks like there might be a typo - I guess this is supposed to still
OR with the previous features instead of replacing them?

From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 8/9] i40e/i40evf: Add support for GSO partial with
 UDP_TUNNEL_CSUM and GRE_CSUM
Date: Wed, 23 Mar 2016 13:21:46 -0700
Message-ID: <CAKgT0Uf5CqHEZ0mjaesuaeOQC-_0b77bbLUdKp8Aq6gUd2XfVA@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232528.14955.87859.stgit@localhost.localdomain>
	<CAEh+42jxjkhoTeC0GK91pmX6XUpnMAxnA-pRhbG0kkQFfa2WXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36065 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbcCWUVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 16:21:47 -0400
Received: by mail-io0-f179.google.com with SMTP id 124so62751529iov.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 13:21:47 -0700 (PDT)
In-Reply-To: <CAEh+42jxjkhoTeC0GK91pmX6XUpnMAxnA-pRhbG0kkQFfa2WXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 12:35 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Fri, Mar 18, 2016 at 4:25 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> index 39b0009253c2..ac3964a9f5c0 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> @@ -9074,7 +9075,12 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
>>         if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
>>                 netdev->features |= NETIF_F_NTUPLE;
>>         if (pf->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE)
>> -               netdev->features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
>> +               netdev->features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
>
> Looks like there might be a typo - I guess this is supposed to still
> OR with the previous features instead of replacing them?

Yes, that was a typo.  It looks like I got it right on the i40vf half
of the patch but didn't get it correct here.

Thanks for catching that, I'll have it fixed for when I push it for net-next.

- Alex

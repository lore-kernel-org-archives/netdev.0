From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 6/9] ethtool: Add support for toggling any of the GSO offloads
Date: Fri, 18 Mar 2016 17:30:25 -0700
Message-ID: <CAKgT0UfTVCfTFgVTtA2sq1fZKVatAk=ciFG-dBtfU-oZmsAyiQ@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232516.14955.2907.stgit@localhost.localdomain>
	<1458346684.2953.16.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33601 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbcCSAa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 20:30:26 -0400
Received: by mail-io0-f175.google.com with SMTP id v123so45210889ioe.0
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 17:30:26 -0700 (PDT)
In-Reply-To: <1458346684.2953.16.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 5:18 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Fri, 2016-03-18 at 16:25 -0700, Alexander Duyck wrote:
>
>> The strings were missing for several of the GSO offloads that are
>> available.  This patch provides the missing strings so that we can toggle
>> or query any of them via the ethtool command.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> ---
>>  net/core/ethtool.c |    3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
>> index 2966cd0d7c93..b3c39d531469 100644
>> --- a/net/core/ethtool.c
>> +++ b/net/core/ethtool.c
>> @@ -82,9 +82,12 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
>>       [NETIF_F_TSO6_BIT] =             "tx-tcp6-segmentation",
>>       [NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
>>       [NETIF_F_GSO_GRE_BIT] =          "tx-gre-segmentation",
>> +     [NETIF_F_GSO_GRE_CSUM_BIT] =     "tx-gre-csum-segmentation",
>
> All of the existing checksum offload names include the word "checksum"
> in full, so I think the new names should do the same.

It isn't a checksum offload though, it is a segmentation offload for a
tunnel that has an outer checksum.  I was hoping to avoid using the
word checksum as that might make it confusing as it is a segmentation
offload, not a checksum offload.

>>       [NETIF_F_GSO_IPIP_BIT] =         "tx-ipip-segmentation",
>>       [NETIF_F_GSO_SIT_BIT] =          "tx-sit-segmentation",
>>       [NETIF_F_GSO_UDP_TUNNEL_BIT] =   "tx-udp_tnl-segmentation",
>> +     [NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] = "tx-udp_tnl-csum-segmentation",
>> +     [NETIF_F_GSO_TUNNEL_REMCSUM_BIT] = "tx-remcsum-segmentation",
>
> I think this should be "tx-tunnel-remote-checksum-segmentation", though
> that is getting quite unwieldy.

Right.  As it is I think we might be coming up on the 32 character
limit for the strings.  Replacing csum with checksum would probably
push us over.

- Alex

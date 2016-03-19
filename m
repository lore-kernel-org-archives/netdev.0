From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 6/9] ethtool: Add support for toggling any of the GSO offloads
Date: Fri, 18 Mar 2016 19:01:16 -0700
Message-ID: <CAEh+42ihKJ30O_i9f7H0KzQBjNrBfQFXN=S3-ZsdYKssBkTSXg@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
 <20160318232516.14955.2907.stgit@localhost.localdomain> <1458346684.2953.16.camel@decadent.org.uk>
 <CAKgT0UfTVCfTFgVTtA2sq1fZKVatAk=ciFG-dBtfU-oZmsAyiQ@mail.gmail.com> <1458351771.2953.22.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:38628 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751734AbcCSCBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 22:01:34 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id E04BB20443
	for <netdev@vger.kernel.org>; Sat, 19 Mar 2016 02:01:32 +0000 (UTC)
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 634C72042C
	for <netdev@vger.kernel.org>; Sat, 19 Mar 2016 02:01:31 +0000 (UTC)
Received: by mail-qg0-f46.google.com with SMTP id w104so115304650qge.1
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 19:01:31 -0700 (PDT)
In-Reply-To: <1458351771.2953.22.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 6:42 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Fri, 2016-03-18 at 17:30 -0700, Alexander Duyck wrote:
>> On Fri, Mar 18, 2016 at 5:18 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
>> > On Fri, 2016-03-18 at 16:25 -0700, Alexander Duyck wrote:
>> > >       [NETIF_F_GSO_IPIP_BIT] =         "tx-ipip-segmentation",
>> > >       [NETIF_F_GSO_SIT_BIT] =          "tx-sit-segmentation",
>> > >       [NETIF_F_GSO_UDP_TUNNEL_BIT] =   "tx-udp_tnl-segmentation",
>> > > +     [NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] = "tx-udp_tnl-csum-segmentation",
>> > > +     [NETIF_F_GSO_TUNNEL_REMCSUM_BIT] = "tx-remcsum-segmentation",
>> > I think this should be "tx-tunnel-remote-checksum-segmentation", though
>> > that is getting quite unwieldy.
>> Right.  As it is I think we might be coming up on the 32 character
>> limit for the strings.  Replacing csum with checksum would probably
>> push us over.
>
> Right, I wasn't even thinking about the static limit!  That does weigh
> rather heavily in favour of abbreviation here.
>
> Please do at least hyphenate "remcsum" though.

I think that remote checksum offload is just a purely internal feature
- that is no device will ever expose support for it, since it is
explicitly to work around lack of hardware support. As a result, I
don't know if it makes sense to show it through ethtool at all.

From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net] net: Generalize ndo_gso_check to ndo_features_check
Date: Tue, 23 Dec 2014 13:54:37 -0800
Message-ID: <CA+mtBx_F-ZbtfW5Mf-wXPF5ML3GMXTVNyxhjQzUjNOXaBW9+jA@mail.gmail.com>
References: <1419264223-30004-1-git-send-email-jesse@nicira.com>
	<CA+mtBx9vYV5i9_u=XMmEgSV3Uj9SEJAZHrKhTgyGgBG9Ojs-dA@mail.gmail.com>
	<CF9D1877D81D214CB0CA0669EFAE020C68D41FA3@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Stringer <joestringer@nicira.com>,
	Eric Dumazet <edumazet@google.com>
To: Sathya Perla <Sathya.Perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:41248 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaLWVyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 16:54:38 -0500
Received: by mail-ig0-f181.google.com with SMTP id l13so6591559iga.8
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 13:54:38 -0800 (PST)
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C68D41FA3@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 10:24 PM, Sathya Perla <Sathya.Perla@emulex.com> wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Tom Herbert
>>
>> On Mon, Dec 22, 2014 at 8:03 AM, Jesse Gross <jesse@nicira.com> wrote:
>> > GSO isn't the only offload feature with restrictions that
>> > potentially can't be expressed with the current features mechanism.
>> > Checksum is another although it's a general issue that could in
>> > theory apply to anything. Even if it may be possible to
>> > implement these restrictions in other ways, it can result in
>> > duplicate code or inefficient per-packet behavior.
>> >
>> > This generalizes ndo_gso_check so that drivers can remove any
>> > features that don't make sense for a given packet, similar to
>> > netif_skb_features(). It also converts existing driver
>> > restrictions to the new format, completing the work that was
>> > done to support tunnel protocols since the issues apply to
>> > checksums as well.
>> >
>> It's a nice feature, but I really hope that this is not used for
>> checksums. We already have a sufficiently general interface for that
>> and checksum is already computed in drivers to work around HW bugs.
>>
> The ndo_featureas_check() interface that includes a means to report
> inability to compute inner checksums on some tunnel types, seems like
> a useful feature. The Skyhawk-R NIC can support inner csum offload for
> either vxlan or nv-gre, but not both simultaneously. So, this ndo_
> is useful in reporting this situation.
> This would also obviate the need to have extra code in the drivers to
> compute csums in the above scenario.
>
You could use it for that, but many drivers already call
skb_checksum_help and I really doubt it makes sense to change all of
those. Besides that, I don't think we should be "encouraging" vendors
to continue developing NICs that do protocol specific checksums. The
general interface (NETIF_HW_CSUM) is incredibly simple and obviates a
whole bunch of complexity in drivers to figure out whether it can
checksum a packet.

Tom

> thanks,
> -Sathya

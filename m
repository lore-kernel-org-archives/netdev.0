From: Felix Fietkau <nbd@nbd.name>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Fri, 6 Jan 2017 14:52:47 +0100
Message-ID: <8836daaa-9638-4502-d079-fd428595f822@nbd.name>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
 <1483706872.4089.8.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Michael Braun <michael-dev@fami-braun.de>
To: Johannes Berg <johannes@sipsolutions.net>,
        =?UTF-8?Q?Linus_L=c3=bcssing?= <linus.luessing@c0d3.blue>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:33623 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751428AbdAFNww (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 08:52:52 -0500
In-Reply-To: <1483706872.4089.8.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-01-06 13:47, Johannes Berg wrote:
> On Mon, 2017-01-02 at 20:32 +0100, Linus Lüssing wrote:
>> Implements an optional, per bridge port flag and feature to deliver
>> multicast packets to any host on the according port via unicast
>> individually. This is done by copying the packet per host and
>> changing the multicast destination MAC to a unicast one accordingly.
> 
> How does this compare and/or relate to the multicast-to-unicast feature
> we were going to add to the wifi stack, particularly mac80211? Do we
> perhaps not need that feature at all, if bridging will have it?
> 
> I suppose that the feature there could apply also to locally generated
> traffic when the AP interface isn't in a bridge, but I think I could
> live with requiring the AP to be put into a bridge to achieve a similar
> configuration?
> 
> Additionally, on an unrelated note, this seems to apply generically to
> all kinds of frames, losing information by replacing the address.
> Shouldn't it have similar limitations as the wifi stack feature has
> then, like only applying to ARP, IPv4, IPv6 and not general protocols?
> 
> Also, it should probably come with the same caveat as we documented for
> the wifi feature:
> 
>     Note that this may break certain expectations of the receiver,
>     such as the ability to drop unicast IP packets received within
>     multicast L2 frames, or the ability to not send ICMP destination
>     unreachable messages for packets received in L2 multicast (which
>     is required, but the receiver can't tell the difference if this
>     new option is enabled.)
> 
> 
> I'll hold off sending my tree in until we see that we really need both
> features, or decide that we want the wifi feature *instead* of the
> bridge feature.
The bridge layer can use IGMP snooping to ensure that the multicast
stream is only transmitted to clients that are actually a member of the
group. Can the mac80211 feature do the same?

- Felix

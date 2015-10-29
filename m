From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] ipv4: use l4 hash for locally generated
 multipath flows
Date: Thu, 29 Oct 2015 08:37:34 -0700
Message-ID: <CALx6S35zh0naXYP_L5rK-BSgPTdfC0=_LhRO0dX1mOtuSS5a3Q@mail.gmail.com>
References: <006ec2edb2d592ab9b90ccc5c084ac8926e811df.1446053264.git.pabeni@redhat.com>
	<1446129070.7476.148.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446130859.4431.17.camel@dhcp-176-88.mxp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Peter_N=C3=B8rlund?= <pch@ordbogen.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33142 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbbJ2Phf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 11:37:35 -0400
Received: by iodd200 with SMTP id d200so49708477iod.0
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 08:37:34 -0700 (PDT)
In-Reply-To: <1446130859.4431.17.camel@dhcp-176-88.mxp.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2015 at 8:00 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Thu, 2015-10-29 at 07:31 -0700, Eric Dumazet wrote:
>> On Wed, 2015-10-28 at 18:39 +0100, Paolo Abeni wrote:
>> > This patch changes how the multipath hash is computed for locally
>> > generated UDP or TCP flows: now the hash comprises also l4 information
>> > (source and destination port).
>> >
>> > This allows better utilization of the available paths when the existing
>> > flows have the same source IP and the same destination IP: with l3 hash,
>> > even when multiple connections are in place simultaneously, a single path
>> > will be used, while with l4 hash we can use all the available paths.
>> >
>> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>>
>> Please note that many skb already have a l4 hash. No need to perform yet
>> another dissection.
>
> This patch do not add dissection code: it use the information provided
> by the available flowi4 structure. Moreover the skb is not available on
> the calling site (in __ip_route_output_key_hash) and pushing it all the
> way will require a lot of intrusive changes. Do you think it's the
> better option ?
>
If there is an associated skb then skb_get_hash should be called to
get the hash. If you only have the flow structure then
get_hash_from_flowi4 (or skb_get_hash_flowi6 for IPv6 should be
called).

Tom

> Paolo
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 3/7] ipv6: improve ipv6_find_hdr() to skip empty
 routing headers
Date: Tue, 4 Dec 2012 10:15:11 -0800
Message-ID: <CAEP_g=_89wPzKi-F9VQaKxM5eAUhSx3KEQhOSJQgTNtfiFQTEw@mail.gmail.com>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
 <1354214149-33651-4-git-send-email-jesse@nicira.com> <20121203140458.GA1596@1984>
 <CAEP_g=-D6f-O1F0B4+xLKfZnY_LjFiHF-UaXD4zVUYctGG3-Ug@mail.gmail.com> <20121203180611.GA20305@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dev@openvswitch.org, Ansis Atteka <aatteka@nicira.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:52278 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751090Ab2LDSPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 13:15:32 -0500
Received: by mail-ob0-f198.google.com with SMTP id un3so18964121obb.1
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 10:15:31 -0800 (PST)
In-Reply-To: <20121203180611.GA20305@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 3, 2012 at 10:06 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Mon, Dec 03, 2012 at 09:28:55AM -0800, Jesse Gross wrote:
>> On Mon, Dec 3, 2012 at 6:04 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> > On Thu, Nov 29, 2012 at 10:35:45AM -0800, Jesse Gross wrote:
>> >> @@ -159,9 +162,10 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>> >>       }
>> >>       len = skb->len - start;
>> >>
>> >> -     while (nexthdr != target) {
>> >
>> > If the offset is set as parameter via ipv6_find_hdr, we now are always
>> > entering the loop even if we found the target header we're looking
>> > for, before that didn't happen.
>> >
>> > Something seems wrong here to me.
>>
>> If the target header is a routing header then you might still need to
>> continue searching because the first one that you see could be empty.
>
> OK, but if it's not a routing header what we're searching for (which
> seems to be the case of netfilter/IPVS) we waste way more cycles on
> copying the IPv6 header again and with way more things that are
> completely useless.

We could add a check to short circuit this but it seems like a
premature optimization to me.

Ansis, can you comment?

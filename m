From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 1/4] ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked sockets
Date: Tue, 27 Oct 2015 09:41:46 -0700
Message-ID: <CALx6S347aZyd1NhDEXsONG_txNC2PSXD-piv4e8kcs_DBFHOeg@mail.gmail.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
	<1445958135-19805-2-git-send-email-hannes@stressinduktion.org>
	<CALx6S36PRh1EmmydMAUhZVxyyAanNYBTRUzTN67=dHnbBTNOGQ@mail.gmail.com>
	<1445963644.1412577.421660985.2D10CC9A@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34739 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169AbbJ0Qlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 12:41:47 -0400
Received: by igpw7 with SMTP id w7so10249149igp.1
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 09:41:47 -0700 (PDT)
In-Reply-To: <1445963644.1412577.421660985.2D10CC9A@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 9:34 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Tue, Oct 27, 2015, at 17:04, Tom Herbert wrote:
>> On Tue, Oct 27, 2015 at 8:02 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> > We cannot reliable calculate packet size on MSG_MORE corked sockets
>> > and thus cannot decide if they are going to be fragmented later on,
>> > so better not use CHECKSUM_PARTIAL in the first place.
>> >
>> MSG_MORE should be independent of checksum offload. If packet is
>> fragmented the fix in ip_output will ensure that skb_checksum_help is
>> properly called.
>
> The probability is that we are going to fragment if MSG_MORE is set,
> because exceeding link mtu is quite probable, see e.g. NFS use case. Why
> not simply use the csum functions during copy-in in that case? It makes
> much more sense to me.
>
For datagram sockets MSG_MORE means that more datagrams will be sent,
it's not used to incrementally add data to a datagram already queued
(SEQPACKET with EOR is for that).

> I don't see a reason to test for fragment length at all, then.
>
> Bye,
> Hannes

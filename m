From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] store complete hash type information in socket buffer...
Date: Thu, 18 Feb 2016 18:22:16 -0800
Message-ID: <CALx6S37736iQM_t80pR3ZH1TiQvCwomcFdajVwf1h=Y7Eq+EKA@mail.gmail.com>
References: <1455525128-27795-1-git-send-email-paul.durrant@citrix.com>
	<20160217.154432.788293606088459412.davem@davemloft.net>
	<1455744601.648.2.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Paul Durrant <paul.durrant@citrix.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36118 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1949016AbcBSCWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 21:22:17 -0500
Received: by mail-io0-f170.google.com with SMTP id l127so94877135iof.3
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 18:22:17 -0800 (PST)
In-Reply-To: <1455744601.648.2.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 1:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On mer., 2016-02-17 at 15:44 -0500, David Miller wrote:
>> From: Paul Durrant <paul.durrant@citrix.com>
>> Date: Mon, 15 Feb 2016 08:32:08 +0000
>>
>> > ...rather than a boolean merely indicating a canonical L4 hash.
>> >
>> > skb_set_hash() takes a hash type (from enum pkt_hash_types) as an
>> > argument but information is lost since only a single bit in the skb
>> > stores whether that hash type is PKT_HASH_TYPE_L4 or not. By using
>> > two bits it's possible to store the complete hash type information.
>> >
>> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
>>
>> Tom and/or Eric, please have a look at this.
>
> I guess my question is simply 'why do we need this' ?
>
> Consuming a bit in our precious sk_buff is not something we want for
> some obscure feature.
>
Right. I think the reason Paul wants this is be able to pass the hash
to a Windows guest. As I pointed out though, we'd also need an
indication that the hash is Toeplitz to be really correct with Windows
interface. The Linux driver interface does allow indicating L2, L3, or
L4 hash with the assumption that differentiation might be useful some
day, but so far it only appears that distinguishing L4 from others has
any value. It would be interesting to know if Windows actually does
anything useful in differentiating L2 and L3 hashes.

Tom

>
>

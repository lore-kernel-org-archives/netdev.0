From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH v2] net: bridge: add compile-time assert for cb struct size
Date: Tue, 3 Mar 2015 16:51:56 +0200
Message-ID: <CAHsH6GuN+of0rKru0oPrYiR_eSJkwzCa2WEU27FKmpzxV19C2g@mail.gmail.com>
References: <1425387211-16807-1-git-send-email-fw@strlen.de>
	<063D6719AE5E284EB5DD2968C1650D6D1CAF3BB7@AcuExch.aculab.com>
	<54F5C51F.5020906@iogearbox.net>
	<063D6719AE5E284EB5DD2968C1650D6D1CAF3C48@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:37850 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbbCCOv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 09:51:56 -0500
Received: by ykq19 with SMTP id 19so16931044ykq.4
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 06:51:56 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAF3C48@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 4:44 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Daniel Borkmann
>> On 03/03/2015 02:50 PM, David Laight wrote:
>> ...
>> >> +  BUILD_BUG_ON(sizeof(struct br_input_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
>> >> +
>> >
>> > What about using something based on:
>> > #define GET_CB(skb, type) ((type *)((skb)->cb + (sizeof (char[(sizeof (type) <= sizeof (skb->cb)) ? 1 : -1] - 1)))
>> > to access skb->sb?
>>
>> That would require to change all skb->cb[] call-sites everywhere.
>
> Well, only once for each type.

Note that there are cases where skb->cb[] used size is greater than
the associated
type.
For example, in packet_rcv() a full hw address is stored in skb->cb[], exceeding
the packet_skb_cb struct size. This is also true for can/raw.c (in
raw_flags()), though
in that specific case the skb->cb[] use could have been wrapped in a struct.

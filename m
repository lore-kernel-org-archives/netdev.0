From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] ipv6 Use get_hash_from_flowi6 for rt6 hash
Date: Wed, 23 Sep 2015 15:45:18 -0700
Message-ID: <CALx6S36iNX_krkKu+khbhw9UiBT+Jt1EFd7QnWq+HjMunKk2Hw@mail.gmail.com>
References: <1443042815-3458631-1-git-send-email-tom@herbertland.com>
	<20150923.142138.873048869450376623.davem@davemloft.net>
	<20150923.145730.671266108610739603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Peter Christensen <pch@ordbogen.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33309 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754840AbbIWWpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 18:45:18 -0400
Received: by iofh134 with SMTP id h134so58653170iof.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 15:45:18 -0700 (PDT)
In-Reply-To: <20150923.145730.671266108610739603.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 2:57 PM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 23 Sep 2015 14:21:38 -0700 (PDT)
>
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Wed, 23 Sep 2015 14:13:35 -0700
>>
>>> In rt6_info_hash_nhsfn replace the custom hashing over flowi6 that is
>>> using xor with a call to common function get_hash_from_flowi6.
>>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>
>> Applied, thanks.
>
> Tom, I just so happened to look over the call paths that lead to this
> function and the flowi6 ports aren't filled in much of the time.
>
> I know your patch doesn't change things one way or the other in this
> area, but I thought I'd bring it up nonetheless.

Yeah, I noticed  there's still a little work to do here. On input put
we should be passing in skb to use skb->hash instead of calculating
it. On ouput we should be getting hash from sk->txhash for connected
sockets.

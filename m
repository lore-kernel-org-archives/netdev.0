From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net-next 1/7] net: Export inet_offloads and inet6_offloads
Date: Mon, 15 Sep 2014 10:32:19 -0700
Message-ID: <CA+mtBx-BASH-MBwoGUXkvEs0oqfwAsgq6y4YjkksF1qA2ftA+w@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<1410750483-3236-2-git-send-email-therbert@google.com>
	<CAJ3xEMgNqZ=qHmALiN_bFC5b3n8Ev-27Z7-KFG5Au6+x2A7=5g@mail.gmail.com>
	<CA+mtBx8ZacxVFEB-odM4qrbawFTWUsijTMFGYBWiLV4Ad22ctw@mail.gmail.com>
	<CAJ3xEMg5Q-qkr-tj0UiFP2tNVLg1P4aT2L2bZk9yWjq+V0zJLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jerry Chu <hkchu@google.com>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:60040 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185AbaIORcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 13:32:20 -0400
Received: by mail-ig0-f177.google.com with SMTP id h15so4360375igd.16
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 10:32:19 -0700 (PDT)
In-Reply-To: <CAJ3xEMg5Q-qkr-tj0UiFP2tNVLg1P4aT2L2bZk9yWjq+V0zJLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 10:15 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Sep 15, 2014 at 6:13 PM, Tom Herbert <therbert@google.com> wrote:
>> On Mon, Sep 15, 2014 at 6:33 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Mon, Sep 15, 2014 at 6:07 AM, Tom Herbert <therbert@google.com> wrote:
>>>> Want to be able to call this in foo-over-udp offloads, etc.
>>>
>>> In the L2 gro case, we did dedicated helpers
>>> gro_find_receive/complete_by_type, not sure what was
>>> the exact rational there but worth checking, jerry?
>>>
>> It allows offload_base to be kept a static, but then
>> gro_find_receive_by_type can't be inlined.
>
>
> so we have two similar locations in the networking stack acting
> differently on the same/similar simple
> matter... a bit problematic maintainance wise, I would say.

Yes, these should be similar. I think we'd need to cleanup
gro_find_receive_by_type first: export udp_offload base and inline
these functions. Have skb_mac_gso_segment call this also.

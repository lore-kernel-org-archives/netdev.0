From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net-next 3/7] fou: Add GRO support
Date: Mon, 15 Sep 2014 10:21:37 -0700
Message-ID: <CA+mtBx_0F=Y-4FMGuuVeJKJqek7e7_TPmgDzR3FXvT-cuSO1bw@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<1410750483-3236-4-git-send-email-therbert@google.com>
	<CAJ3xEMhwdkNDZxSZGw3dtnfoyPHBiOTw-c5DvQPpFZTf1yhEhQ@mail.gmail.com>
	<CA+mtBx-945Ku0OtcYGE195=R7cF5AHgacQeh8OPtC7NOQgMNvw@mail.gmail.com>
	<CAJ3xEMh-76WMatuknjywQK=ZVWG8UM5swEC0CE5FTv-ts-Jk6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:53241 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbaIORVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 13:21:38 -0400
Received: by mail-ig0-f172.google.com with SMTP id h3so4306936igd.11
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 10:21:37 -0700 (PDT)
In-Reply-To: <CAJ3xEMh-76WMatuknjywQK=ZVWG8UM5swEC0CE5FTv-ts-Jk6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 10:03 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Sep 15, 2014 at 6:10 PM, Tom Herbert <therbert@google.com> wrote:
>> On Mon, Sep 15, 2014 at 8:00 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Mon, Sep 15, 2014 at 6:07 AM, Tom Herbert <therbert@google.com> wrote:
>>>> Implement fou_gro_receive and fou_gro_complete, and populate these
>>>> in the correponsing udp_offloads for the socket. Added ipproto to
>>>> udp_offloads and pass this from UDP to the fou GRO routine in proto
>>>> field of napi_gro_cb structure.
>>>
>>>
>>> Do we really need that  extra hop of fou4_gro_receive/complete?
>>> can't we somehow plant the gro receive/complete (say) GRE handlers in
>>> the udp offload
>>> struct with the UDP port that related to (say) GRE over UDP tunneling?
>>>
>> That would be nice, but it isn't obvious to me how to manage the
>> references. The offload functions are accessed with RCU pretty consistently.
>
> Currently udp_gro_receive calls rcu_read_lock() before it invokes
> fou4/6_gro_receive
> and rcu_read_unlock after the fou calls returns. The Fou call repeats
> the same practice
> w.r.t the (say) GRE gro receive callback, so... what happens if we
> eliminate the fou part all together?

Yes, we could conceivably index into inet_offloads directly from
udp_gro_receive in lieu of calling the offload functions in the
structure. It is more special case code in udp though and I'm not sure
that makes it a win.

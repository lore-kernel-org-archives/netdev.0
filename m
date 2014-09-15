From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net-next 3/7] fou: Add GRO support
Date: Mon, 15 Sep 2014 08:10:58 -0700
Message-ID: <CA+mtBx-945Ku0OtcYGE195=R7cF5AHgacQeh8OPtC7NOQgMNvw@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<1410750483-3236-4-git-send-email-therbert@google.com>
	<CAJ3xEMhwdkNDZxSZGw3dtnfoyPHBiOTw-c5DvQPpFZTf1yhEhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:32903 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027AbaIOPLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 11:11:00 -0400
Received: by mail-ig0-f178.google.com with SMTP id a13so4100088igq.17
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 08:10:59 -0700 (PDT)
In-Reply-To: <CAJ3xEMhwdkNDZxSZGw3dtnfoyPHBiOTw-c5DvQPpFZTf1yhEhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 8:00 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Sep 15, 2014 at 6:07 AM, Tom Herbert <therbert@google.com> wrote:
>> Implement fou_gro_receive and fou_gro_complete, and populate these
>> in the correponsing udp_offloads for the socket. Added ipproto to
>> udp_offloads and pass this from UDP to the fou GRO routine in proto
>> field of napi_gro_cb structure.
>
>
> Do we really need that  extra hop of fou4_gro_receive/complete?
> can't we somehow plant the gro receive/complete (say) GRE handlers in
> the udp offload
> struct with the UDP port that related to (say) GRE over UDP tunneling?
>
That would be nice, but it isn't obvious to me how to manage the
references. The offload functions are accessed with RCU pretty
consistently.

Tom

> Or.

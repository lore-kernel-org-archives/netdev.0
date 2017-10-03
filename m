From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 2/2] flow_dissector: dissect tunnel info
Date: Tue, 3 Oct 2017 11:17:46 -0700
Message-ID: <CALx6S37K3Gif=AGk48CXs9JgrcDbdpfqMZWK+0j95UHG0hvpZg@mail.gmail.com>
References: <1506933676-20121-1-git-send-email-simon.horman@netronome.com>
 <1506933676-20121-3-git-send-email-simon.horman@netronome.com>
 <CALx6S34ULzKX=Q+CSdEuXVAA12MMM1oQ=x7JEV8EmD-2qaviNA@mail.gmail.com> <20171003094052.GA20592@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:56362 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdJCSRr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 14:17:47 -0400
Received: by mail-qt0-f195.google.com with SMTP id e19so10757204qta.13
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 11:17:47 -0700 (PDT)
In-Reply-To: <20171003094052.GA20592@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 3, 2017 at 2:40 AM, Simon Horman <simon.horman@netronome.com> wrote:
> On Mon, Oct 02, 2017 at 01:37:55PM -0700, Tom Herbert wrote:
>> On Mon, Oct 2, 2017 at 1:41 AM, Simon Horman <simon.horman@netronome.com> wrote:
>> > Move dissection of tunnel info from the flower classifier to the flow
>> > dissector where all other dissection occurs.  This should not have any
>> > behavioural affect on other users of the flow dissector.
>
> ...

> I feel that we are circling back the perennial issue of flower using the
> flow dissector in a somewhat broader/different way than many/all other
> users of the flow dissector.
>
Simon,

It's more like __skb_flow_dissect is already an incredibly complex
function and because of that it's difficult to maintain. We need to
measure changes against that fact. For this patch, there is precisely
one user (cls_flower.c) and it's not at all clear to me if there will
be ever any more (e.g. for hashing we don't need tunnel info). IMO, it
should be just as easy and less convolution for everyone to have
flower call __skb_flow_dissect_tunnel_info directly and not call if
from __skb_flow_dissect.

Tom

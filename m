From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 2/2] flow_dissector: dissect tunnel info
Date: Tue, 3 Oct 2017 11:40:53 +0200
Message-ID: <20171003094052.GA20592@netronome.com>
References: <1506933676-20121-1-git-send-email-simon.horman@netronome.com>
 <1506933676-20121-3-git-send-email-simon.horman@netronome.com>
 <CALx6S34ULzKX=Q+CSdEuXVAA12MMM1oQ=x7JEV8EmD-2qaviNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:55829 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdJCJk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 05:40:56 -0400
Received: by mail-wr0-f176.google.com with SMTP id l39so5875501wrl.12
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 02:40:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S34ULzKX=Q+CSdEuXVAA12MMM1oQ=x7JEV8EmD-2qaviNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 02, 2017 at 01:37:55PM -0700, Tom Herbert wrote:
> On Mon, Oct 2, 2017 at 1:41 AM, Simon Horman <simon.horman@netronome.com> wrote:
> > Move dissection of tunnel info from the flower classifier to the flow
> > dissector where all other dissection occurs.  This should not have any
> > behavioural affect on other users of the flow dissector.

...

Hi Tom,

> Simon,
> 
> I think I'm missing something fundamental here. This code is
> populating flow dissector keys not based on the contents of the packet
> like rest of the flow dissector, but on external meta data related to
> the packet which I believe is constant during the whole flow
> dissection.

Yes, I believe that is correct on all counts.

> Why can't this be handled by the caller?

It certainly can be. And indeed it was before this patch. But it seems odd
for some population of dissector keys to occur in the dissector and some
elsewhere.

I feel that we are circling back the perennial issue of flower using the
flow dissector in a somewhat broader/different way than many/all other
users of the flow dissector.

> Also, if I read this correctly, this code could be called multiple times
> and it seems like it does the exact same thing in each call.

I'm not sure what you are getting at there. If there are flower classifiers
for the same device at different priority levels then the dissection
will be called multiple times and the data in question cannot have changed
as far as I know. But this was also the case before this patch.

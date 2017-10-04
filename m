From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] flow_dissector: dissect tunnel info
Date: Wed, 4 Oct 2017 20:07:15 +0200
Message-ID: <20171004180715.GH1895@nanopsycho>
References: <1506933676-20121-1-git-send-email-simon.horman@netronome.com>
 <1506933676-20121-3-git-send-email-simon.horman@netronome.com>
 <CALx6S34ULzKX=Q+CSdEuXVAA12MMM1oQ=x7JEV8EmD-2qaviNA@mail.gmail.com>
 <20171003094052.GA20592@netronome.com>
 <CALx6S37K3Gif=AGk48CXs9JgrcDbdpfqMZWK+0j95UHG0hvpZg@mail.gmail.com>
 <20171004080856.GB6378@netronome.com>
 <20171004081558.GE1895@nanopsycho>
 <CALx6S36c=BUXb7-53Ym_SZYuWqmPfEqdYUwwxyM78SfBnEPL4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:49592 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdJDSHR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 14:07:17 -0400
Received: by mail-wm0-f44.google.com with SMTP id b189so20538282wmd.4
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 11:07:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36c=BUXb7-53Ym_SZYuWqmPfEqdYUwwxyM78SfBnEPL4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 04, 2017 at 05:52:54PM CEST, tom@herbertland.com wrote:
>On Wed, Oct 4, 2017 at 1:15 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Oct 04, 2017 at 10:08:57AM CEST, simon.horman@netronome.com wrote:
>>>On Tue, Oct 03, 2017 at 11:17:46AM -0700, Tom Herbert wrote:
>>>> On Tue, Oct 3, 2017 at 2:40 AM, Simon Horman <simon.horman@netronome.com> wrote:
>>>> > On Mon, Oct 02, 2017 at 01:37:55PM -0700, Tom Herbert wrote:
>>>> >> On Mon, Oct 2, 2017 at 1:41 AM, Simon Horman <simon.horman@netronome.com> wrote:
>>>> >> > Move dissection of tunnel info from the flower classifier to the flow
>>>> >> > dissector where all other dissection occurs.  This should not have any
>>>> >> > behavioural affect on other users of the flow dissector.
>>>> >
>>>> > ...
>>>>
>>>> > I feel that we are circling back the perennial issue of flower using the
>>>> > flow dissector in a somewhat broader/different way than many/all other
>>>> > users of the flow dissector.
>>>> >
>>>> Simon,
>>>>
>>>> It's more like __skb_flow_dissect is already an incredibly complex
>>>> function and because of that it's difficult to maintain. We need to
>>>> measure changes against that fact. For this patch, there is precisely
>>>> one user (cls_flower.c) and it's not at all clear to me if there will
>>>> be ever any more (e.g. for hashing we don't need tunnel info). IMO, it
>>>> should be just as easy and less convolution for everyone to have
>>>> flower call __skb_flow_dissect_tunnel_info directly and not call if
>>>> from __skb_flow_dissect.
>>>
>>>Hi Tom,
>>>
>>>my original suggestion was just that, but Jiri indicated a strong preference
>>>for the approach taken by this patch. I think we need to widen the
>>>participants in this discussion.
>>
>> I like the __skb_flow_dissect to be the function to call and it will do
>> the job according to the configuration. I don't like to split in
>> multiple calls.
>
>Those are not technical arguments. As I already mentioned, I don't
>like it when we add stuff for the benefit of a 1% use case that
>negatively impacts the rest of the 99% cases which is what I believe
>is happening here.

Yeah. I just wanted the flow dissector to stay compact. But if needed,
could be split. I just fear that it will become a mess that's all.


>
>> Does not make sense in the most of the cases as the
>> dissection state would have to be carried in between calls.
>
>Please elaborate. This code is being moved into __skb_flow_dissect, so
>the functionality was already there. I don't see any description in
>this discussion that things were broken and that this patch is a
>necessary fix.

Yeah, you are right.


>
>Thanks,
>Tom

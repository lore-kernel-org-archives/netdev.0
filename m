From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Sat, 24 Dec 2016 22:03:43 +0100
Message-ID: <585EE2AF.2000100@iogearbox.net>
References: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net> <CAM_iQpXadrGWJYqizEkq+xmMKVV9krrcCWKur=ZCRZBS9Mx_8w@mail.gmail.com> <CAM_iQpX3Sk_YGDmvY-yj0CxPbG5qfT7P7ioNgY5Lb_DqsTWh6Q@mail.gmail.com> <585ADFEB.3030206@iogearbox.net> <CAM_iQpUEUmJpjQYV7HV+4NVtGe6D-yZs6=YizcDtf7dogkNR0Q@mail.gmail.com> <585AEF24.4070800@iogearbox.net> <CAM_iQpW9Ly+fMEiBtHq4XwUgvt89-5uE2Bwdw1FXJGV3=eY1ZA@mail.gmail.com> <585C6F49.5030900@iogearbox.net> <CAM_iQpX2X-WHbf1VxfQzh_-YUEqk=o6B+uYfYhj_45jJGaFSfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Shahar Klein <shahark@mellanox.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44811 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752118AbcLXVDs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2016 16:03:48 -0500
In-Reply-To: <CAM_iQpX2X-WHbf1VxfQzh_-YUEqk=o6B+uYfYhj_45jJGaFSfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/24/2016 08:34 AM, Cong Wang wrote:
> On Thu, Dec 22, 2016 at 4:26 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 12/22/2016 08:05 PM, Cong Wang wrote:
>>> On Wed, Dec 21, 2016 at 1:07 PM, Daniel Borkmann <daniel@iogearbox.net>
>>> wrote:
>>>>
>>>> Ok, you mean for net. In that case I prefer the smaller sized fix to be
>>>> honest. It also covers everything from the point where we fetch the chain
>>>> via cops->tcf_chain() to the end of the function, which is where most of
>>>> the complexity resides, and only the two mentioned commits do the relock,
>>>
>>> I really wish the problem is only about relocking, but look at the code,
>>> the deeper reason why we have this bug is the complexity of the logic
>>> inside tc_ctl_tfilter(): 1) the replay logic is hard, we have to make it
>>> idempotent; 2) the request logic itself is hard, because of tc filter
>>> design
>>> and implementation.
>>>
>>> This is why I worry more than just relocking.
>>
>> But do you have a concrete 2nd issue/bug you're seeing? It rather sounds to
>> me your argument is more about fear of complexity on tc framework itself.
>> I agree it's complex, and tc_ctl_tfilter() is quite big in itself, where it
>> would be good to reduce it's complexity into smaller pieces. But it's not
>> really related to the fix itself, reducing complexity requires significantly
>> more and deeper work on the code. We can rework tc_ctl_tfilter() in net-next
>> to try to simplify it, sure, but I don't get why we have to discuss so much
>> on this matter in this context, really.
>
> Thanks for ignoring my point 1) above... You are dragging the discussion
> further.

I don't think so. The analysis and patch I proposed provides an explanation
of how we get into the seen endless loop, it provides a logical fix for it,
which has been reviewed by others and it has been tested extensively that it
resolves the issue, which was easily reproducible for the reporter and that
after the fix it never occurred again. The delta is absolutely simple and
really low risk. Given this function has not much changed over time, also
distros could pick it up that have a much older base kernel than current
stable ones. This initiated follow-up discussion we're having here in general
is dragging the focus away for everyone, and quite frankly I'm getting tired
of discussing it. I have stated my preferences, you have stated yours, and
we're only repeating ourselves in circles which isn't helpful in any way,
the discussion is not about some concrete bug in the logic to fix anymore
(otherwise please name it). Hence my proposal that everything else can wait
and be done in net-next.

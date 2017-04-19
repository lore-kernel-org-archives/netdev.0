From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: add time filter for
 action dumping
Date: Wed, 19 Apr 2017 06:44:50 -0400
Message-ID: <29f38cac-bf9e-4a57-f237-d95017565d13@mojatatu.com>
References: <1492350973-6846-1-git-send-email-jhs@emojatatu.com>
 <20170418151259.72eaa05a@cakuba.lan>
 <930f107b-ac5f-3fab-445b-9050437c1909@mojatatu.com>
 <20170418205525.7d8d18a1@cakuba.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com, jiri@resnulli.us
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34666 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761667AbdDSKox (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 06:44:53 -0400
Received: by mail-it0-f66.google.com with SMTP id 193so1901842itm.1
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 03:44:52 -0700 (PDT)
In-Reply-To: <20170418205525.7d8d18a1@cakuba.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-18 11:55 PM, Jakub Kicinski wrote:
> On Tue, 18 Apr 2017 21:37:12 -0400, Jamal Hadi Salim wrote:
>> On 17-04-18 06:12 PM, Jakub Kicinski wrote:

[..]
>> I see both being fine from that perspective - you dont need 100%
>> accuracy. Just something that is within reason of a small delta
>> of time.
>
> I'm just referring to the theoretical possibility that if the dumping
> process gets preempted for long enough you may loose samples.  Just
> because the dumping process cannot control when kernel executes this
> line:
>
> 	jiffy_wanted = jiffies - jiffy_msecs;
>
> It could in theory be few seconds after the request was made.  Perhaps
> using timestamps from a proper time sources instead of the notion of
> "last X seconds" would solve that?


Good point which i didnt mention as part of the drawbacks. This
is a tradeoff. We dont need to be 100% accurate[1].
The timestamps on the action entries in the kernel are in jiffies;
a lot simpler to do jiffy comparison. If you used a different
timestamp source you'd need to convert for every comparison you
make (i am not sure how costly is when you have many actions).

In use cases i am familiar with, there is a user process app which
opens the socket once and issues dumps every X seconds (ranging from
5-120 seconds). So we will re-issue the dump regardless. Yes
it would be an issue if said application keeps getting pre-empted
and that jiffy computation was always off - but not sure under
what circumstances that could be a common scenario.

cheers,
jamal

[1] As an example, dumps are never 100% accurate you could iterate
  something that then changes while you are in the middle of dumping
  which then renders an already dumped entity obsolete.

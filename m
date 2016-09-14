From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net 1/1] net sched actions: fix GETing actions
Date: Wed, 14 Sep 2016 07:33:27 -0400
Message-ID: <61972f5c-b2b7-efca-4068-1b3af9aabbf4@mojatatu.com>
References: <1473721658-6034-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpWDNzceBLqzVibyyqExk5MXajJCt6Yu3KkC2r2poU0DQQ@mail.gmail.com>
 <f24e1121-84c8-01d1-23cd-1288ba1402aa@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35375 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760636AbcINLda (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 07:33:30 -0400
Received: by mail-it0-f67.google.com with SMTP id e20so1249079itc.2
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 04:33:30 -0700 (PDT)
In-Reply-To: <f24e1121-84c8-01d1-23cd-1288ba1402aa@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-13 03:47 PM, Jamal Hadi Salim wrote:
> On 16-09-13 12:20 PM, Cong Wang wrote:
>> On Mon, Sep 12, 2016 at 4:07 PM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:

[..]
>> I am still trying to understand this piece, so here you hold the refcnt
>> for the same action used by the later iteration? Otherwise there is
>> almost none user inbetween hold and release...
>>
>> The comment you add is not clear to me, we use RTNL/RCU to
>> sync destroy and replace, so how could that happen?
>>
>
> I was worried about the destroy() hitting an error in that function.
> If an action already existed and all we asked for was to
> replace some attribute it would be deleted. It was the way the code was
> before your changes so i just restored it to its original form.
>

And I have verified this is needed. I went and made gact return
a failure if you replace something. I added a gact action; then
when i replaced it failed. And when it failed it replace the existing
action.
I then tried another experiment and batch replaced several actions
including the one i know would fail. I placed the failing action in
the middle and hallelujah, all the actions before the middle one got
deleted.

So please ACK this so we can move forward.

cheers,
jamal

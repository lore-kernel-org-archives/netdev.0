From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 17 Apr 2017 07:58:36 -0700
Message-ID: <1492441116.10587.96.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
         <20170417081936.GA1892@nanopsycho.orion>
         <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
         <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
         <7a49a797-d9cb-37c1-e46b-bec6888539b9@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36583 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751738AbdDQO6i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 10:58:38 -0400
Received: by mail-pf0-f196.google.com with SMTP id i5so25201670pfc.3
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 07:58:38 -0700 (PDT)
In-Reply-To: <7a49a797-d9cb-37c1-e46b-bec6888539b9@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-17 at 10:02 -0400, Jamal Hadi Salim wrote:
> On 17-04-17 09:10 AM, Eric Dumazet wrote:
> 
> [..]
> >
> > We can not assume user programs properly cleared the paddings anyway.
> >
> > Using them for 'new features' is risky, since it might break programs.
> >
> > So the safe way is using new attributes really.
> 
> Since we agreed to have longer discussions on uapis
> when we met I'd like to digress:
> Can we talk about what it means to define pads in data
> structures and then never using them?
> As an example, no-one is setting these fields anywhere on any
> app i know of. Would a union not be good enough for new name
> vs old name? old binaries should continue to work.
> Breakage with any app during compile should be fixable
> within the breaking app (since whoever it is would have source).
> Maybe by breaking some weird app we can experiment on finding
> out.
> 
> My contention is that it is not nice to continue to define uapi
> pads and  then say they cant be used ever.

Very often, pads are there because of ABI constraints.

We 'name' them to make clear to developers that they are there,
and avoid security issues, because of say few bytes from kernel stack
are copied to user space.

struct foo {
  __u32 a;
  __u16 b;
};


Note that the 16bit padding is there, even if you do not name it.

Once this structure had been exported to some include file and in a
kernel, there is little point trying to 'reuse' the padding, unless for
very specific cases.

If you name paddings, then developers might think about it.

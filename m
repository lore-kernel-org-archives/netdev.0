From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 24 Apr 2017 08:49:00 -0400
Message-ID: <2ca4266f-a164-d2ad-37fa-45f7ae354eb8@mojatatu.com>
References: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
 <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
 <20170420135915.GE1886@nanopsycho.orion>
 <a0d70dc5-b0cb-c54e-7d98-93099b68c247@mojatatu.com>
 <20170420142453.GF1886@nanopsycho.orion>
 <20170424091455.GA25218@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        Tom Herbert <tom@herbertland.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33180 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1170130AbdDXMtE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 08:49:04 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so48857837ioi.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 05:49:04 -0700 (PDT)
In-Reply-To: <20170424091455.GA25218@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 05:14 AM, Simon Horman wrote:
[..]

> Jamal, I am confused about why are you so concerned about the space
> consumed by this attribute, it's per-message, right? Is it the bigger
> picture you are worried about - a similar per-entry flag at some point in
> the future?


To me the two worries are one and the same.

Jiri strongly believes (from a big picture view) we must use
TLVs for extensibility.
While I agree with him in general i have strong reservations
in this case because i can get both extensibility and
build for performance with using a flag bitmask as the
content of the TLV.

A TLV consumes 64 bits minimum. It doesnt matter if we decide
to use a u8 or a u16, we are still sending 64 bits on that
TLV with the rest being PADding. Not to be melodramatic, but
the worst case scenario of putting everything in a TLV for 32
flags is using about 30x more space than using a bitmask.

Yes, space is important and if i can express upto 32 flags
with one TLV rather than 32 TLVs i choose one TLV.
I am always looking for ways to filter out crap i dont need
when i do stats collection. I have numerous wounds from fdb
entries which decided to use a TLV per flag.

The design approach we have used in netlink is: flags start
as a bitmap (whether they are on main headers or TLVs); they may be
complemented with a bitmask/selector (refer to IFLINK messages).

Lets look at this specific patch I have sending. I have already
changed it 3 times and involved a churn of 3 different flags.
If you asked me in the beggining i wouldve scratched my head
thinking for a near term use for bit #3, #4 etc,

I am fine with the counter-Postel view of having the kernel
validate that appropriate bits are set as long as we dont make
user space to now start learning how to play acrobatics.

cheers,
jamal

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 24 Apr 2017 16:20:58 +0200
Message-ID: <20170424142058.GA26625@salvia>
References: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
 <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
 <20170420135915.GE1886@nanopsycho.orion>
 <a0d70dc5-b0cb-c54e-7d98-93099b68c247@mojatatu.com>
 <20170420142453.GF1886@nanopsycho.orion>
 <20170424091455.GA25218@vergenet.net>
 <2ca4266f-a164-d2ad-37fa-45f7ae354eb8@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36456 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1172137AbdDXOVF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 10:21:05 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id EFD07E0427
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 16:20:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DDBFAFF2CF
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 16:20:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7B00DA728
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 16:20:55 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <2ca4266f-a164-d2ad-37fa-45f7ae354eb8@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 08:49:00AM -0400, Jamal Hadi Salim wrote:
> On 17-04-24 05:14 AM, Simon Horman wrote:
> [..]
> 
> >Jamal, I am confused about why are you so concerned about the space
> >consumed by this attribute, it's per-message, right? Is it the bigger
> >picture you are worried about - a similar per-entry flag at some point in
> >the future?
> 
> 
> To me the two worries are one and the same.
> 
> Jiri strongly believes (from a big picture view) we must use
> TLVs for extensibility.
> While I agree with him in general i have strong reservations
> in this case because i can get both extensibility and
> build for performance with using a flag bitmask as the
> content of the TLV.
> 
> A TLV consumes 64 bits minimum. It doesnt matter if we decide
> to use a u8 or a u16, we are still sending 64 bits on that
> TLV with the rest being PADding. Not to be melodramatic, but
> the worst case scenario of putting everything in a TLV for 32
> flags is using about 30x more space than using a bitmask.
> 
> Yes, space is important and if i can express upto 32 flags
> with one TLV rather than 32 TLVs i choose one TLV.
> I am always looking for ways to filter out crap i dont need
> when i do stats collection. I have numerous wounds from fdb
> entries which decided to use a TLV per flag.
> 
> The design approach we have used in netlink is: flags start
> as a bitmap (whether they are on main headers or TLVs); they may be
> complemented with a bitmask/selector (refer to IFLINK messages).
> 
> Lets look at this specific patch I have sending. I have already
> changed it 3 times and involved a churn of 3 different flags.
> If you asked me in the beggining i wouldve scratched my head
> thinking for a near term use for bit #3, #4 etc,
> 
> I am fine with the counter-Postel view of having the kernel
> validate that appropriate bits are set as long as we dont make
> user space to now start learning how to play acrobatics.

jamal, what performance concern you have in building this error
message? TLVs is the most flexible way. And this is error path, so we
should build this message rarely, only if the user sends us something
incorrect, why bother...

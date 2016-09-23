From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Fri, 23 Sep 2016 08:11:06 +0300
Message-ID: <20160923081106.73fb48df@halley>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35754 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752747AbcIWFLT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 01:11:19 -0400
Received: by mail-wm0-f67.google.com with SMTP id 133so791119wmq.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 22:11:18 -0700 (PDT)
In-Reply-To: <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 22 Sep 2016 19:40:15 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-09-22 09:21 AM, Shmulik Ladkani wrote:
> > From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> >
> > Up until now, 'action mirred' supported only egress actions (either
> > TCA_EGRESS_REDIR or TCA_EGRESS_MIRROR).
> >
> > This patch implements the corresponding ingress actions
> > TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.
> >
> > This allows attaching filters whose target is to hand matching skbs into
> > the rx processing of a specified device.
> 
> Thank you for doing this. There was something that made me remove
> initial support for this feature - I am blanking out right now but
> will find my notes and give more details.

Thanks Jamal, appreciate any details.

Was wondering why it's missing, googled a bit with no meaningful
results, so speculated the following:

Some time long ago, initial 'mirred' purpose was to facilitate ifb.
Therefore 'egress redirect' was implemented. Jamal probably left the
'ingress' support for a later time :)

One interesting usecase for 'ingress redirect' is creating "rx bouncing"
construct (like macvlan/macvtap/ipvlan) but applied according to custom
logic.

> It may be around preventing loops maybe.

Could be, but personally, I treat these constructs as (powerful)
building blocks, and "with great power comes great responsibility".

Even today, one may create loops using existing 'egress redirect',
e.g. this rediculously errorneous construct:

 # ip l add v0 type veth peer name v0p 
 # tc filter add dev v0p parent ffff: basic \
    action mirred egress redirect dev v0

Regards,
Shmulik

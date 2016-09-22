From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Thu, 22 Sep 2016 11:42:08 -0700
Message-ID: <1474569728.23058.146.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
         <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
         <1474556053.23058.111.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160922212745.789734c5@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36381 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936373AbcIVSmK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 14:42:10 -0400
Received: by mail-pf0-f193.google.com with SMTP id n24so4126938pfb.3
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 11:42:10 -0700 (PDT)
In-Reply-To: <20160922212745.789734c5@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-22 at 21:27 +0300, Shmulik Ladkani wrote:
> On Thu, 22 Sep 2016 07:54:13 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Hmm... we probably need to apply the full rcu protection before this
> > patch.
> > 
> > https://patchwork.ozlabs.org/patch/667680/
> 
> Are you referring to order of application into net-next?
> 
> This patch seems to present no new tcf_mirred_params members nor
> need-to-be-protected code regions (please, correct me if wrong).
> So it does not _depend_ on the 'full rcu fixes', does it?

No, simply a reminder that we run lockless there, so you might need to
read some control variables once, and in a consistent way.

(Or a concurrent writer could change params in the middle of the
function)

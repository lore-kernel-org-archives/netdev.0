From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net/sched: reset block pointer in tcf_block_put()
Date: Fri, 11 Aug 2017 22:32:46 +0200
Message-ID: <20170811203246.GA32076@breakpoint.cc>
References: <150235751251.493255.14955523507789154918.stgit@buzz>
 <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53538 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753256AbdHKUfG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 16:35:06 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Aug 10, 2017 at 2:31 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
> > In previous API tcf_destroy_chain() could be called several times and
> > some schedulers like hfsc and atm use that. In new API tcf_block_put()
> > frees block but leaves stale pointer, second call will free it once again.
> 
> Which call path do we call tcf_block_put() for multiple times on
> the same block? Please be specific, it is not obvious.

you can use tools/testing/selftests/net/rtnetlink.sh to reproduce this
(kernel panics on delete of root qdisc).

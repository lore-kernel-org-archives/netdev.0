From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH] net/sched: reset block pointer in tcf_block_put()
Date: Fri, 11 Aug 2017 23:36:45 +0300
Message-ID: <ad81a570-dff5-7c74-170e-70e764778cba@yandex-team.ru>
References: <150235751251.493255.14955523507789154918.stgit@buzz>
 <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1m.cmail.yandex.net ([5.255.216.198]:60647 "EHLO
        forwardcorp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753517AbdHKUlx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 16:41:53 -0400
In-Reply-To: <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11.08.2017 23:18, Cong Wang wrote:
> On Thu, Aug 10, 2017 at 2:31 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>> In previous API tcf_destroy_chain() could be called several times and
>> some schedulers like hfsc and atm use that. In new API tcf_block_put()
>> frees block but leaves stale pointer, second call will free it once again.
> 
> Which call path do we call tcf_block_put() for multiple times on
> the same block? Please be specific, it is not obvious.
> 

For example in hfsc_destroy_qdisc() since a4aebb83cf0da0363684f1c339f7e6149a3e74c1
second time in hfsc_destroy_class() called from it.

Actually, I see the same pattern in all classy qdiscs.

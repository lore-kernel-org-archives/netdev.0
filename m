From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net-next v2] net_sched: use idr to allocate bpf filter
 handles
Date: Tue, 26 Sep 2017 01:47:57 +0200
Message-ID: <59C995AD.8090001@iogearbox.net>
References: <20170925171351.4956-1-xiyou.wangcong@gmail.com> <59C97244.30301@iogearbox.net> <CAM_iQpUKURMfZOyTMbgVFG43rgUg8-3yAAVtEmPja5T6xkZpjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36802 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933685AbdIYXsA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 19:48:00 -0400
In-Reply-To: <CAM_iQpUKURMfZOyTMbgVFG43rgUg8-3yAAVtEmPja5T6xkZpjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2017 01:11 AM, Cong Wang wrote:
> On Mon, Sep 25, 2017 at 2:16 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 09/25/2017 07:13 PM, Cong Wang wrote:
[...]
>> There's this condition in the code before above idr allocations,
>> I think also in other classifiers:
>>
>>          if (oldprog) {
>>                  if (handle && oldprog->handle != handle) {
>>                          ret = -EINVAL;
>>                          goto errout;
>>                  }
>>          }
>
> Sure. If we use handle to find oldprog, it should have the
> same handle. cls_bpf_get() guarantees it. This check is
> redundant.

Good point, we should just test for 'oldprog && oldprog->handle !=
handle' and bail out then, otherwise it's just irritating. I can
see to fix this up later. Seems fine to me then, thanks!

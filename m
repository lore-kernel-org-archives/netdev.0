From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] net/flow: fix fc->percpu NULL pointer dereference
Date: Fri, 9 Jun 2017 17:06:53 +0800
Message-ID: <CAPwn2JR8MUauO44qAeb3tw93PuQHEbO_8Tocs-ZW8Y9ZK+Ln8A@mail.gmail.com>
References: <1496996036-22077-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JSeKnspZpnWTXsze7sCSXJ9mbq2K3-mu-muuy8iT4A1qw@mail.gmail.com>
 <20170609083255.GR22049@secunet.com> <CADvbK_dn9QMd8_yRsBMZnjstxjy_L-Pc_UPkyNbyZ=0OORu85A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33317 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbdFIJGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 05:06:54 -0400
Received: by mail-io0-f181.google.com with SMTP id t87so10804714ioe.0
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 02:06:54 -0700 (PDT)
In-Reply-To: <CADvbK_dn9QMd8_yRsBMZnjstxjy_L-Pc_UPkyNbyZ=0OORu85A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-06-09 16:43 GMT+08:00 Xin Long <lucien.xin@gmail.com>:
> On Fri, Jun 9, 2017 at 4:32 PM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
>> On Fri, Jun 09, 2017 at 04:23:01PM +0800, Hangbin Liu wrote:
>>> Hi Steffen,
>>>
>>> BTW, If we put the check in xfrm_policy_flush(), we can prevent it earlier.
>>> But If we put the check in flow_cache_percpu_empty(), we can prevent
>>> other functions set fc->percpu to NULL, although not much possible : )
>>>
>>> So I'm not quite sure whether we should put the check in
>>> flow_cache_percpu_empty() or in xfrm_policy_flush().
>>
>> Can't we just call xfrm_policy_fini() first and then flow_cache_fini()?

Yes, that would be easy fix. I have been thinking about that.  But if we change
 the order in xfrm_net_exit(), do we also need to change the order in
 xfrm_net_init()? That would change a lot.

If no need, that would be good.

>>
> That would be a better fix. seems safe as what flow_cache_fini does
> is only to free fcp->hash_table and stop timer, I didn't see  it has
> any dependence on xfrm_policy stuff.

I'm not familiar about this part. So not sure about the influence if we free
the flow cache after xfrm_policy_fini(). I need do some test first.

I would also be appreciate if you or some one could make sure if it doesn't
influence anything.

Thanks
Hangbin

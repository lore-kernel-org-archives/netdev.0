From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] net/flow: fix fc->percpu NULL pointer dereference
Date: Fri, 9 Jun 2017 16:43:59 +0800
Message-ID: <CADvbK_dn9QMd8_yRsBMZnjstxjy_L-Pc_UPkyNbyZ=0OORu85A@mail.gmail.com>
References: <1496996036-22077-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JSeKnspZpnWTXsze7sCSXJ9mbq2K3-mu-muuy8iT4A1qw@mail.gmail.com> <20170609083255.GR22049@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        David Miller <davem@davemloft.net>,
        network dev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:33495 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751412AbdFIIoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 04:44:01 -0400
Received: by mail-qt0-f171.google.com with SMTP id u12so68446955qth.0
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 01:44:00 -0700 (PDT)
In-Reply-To: <20170609083255.GR22049@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 9, 2017 at 4:32 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Fri, Jun 09, 2017 at 04:23:01PM +0800, Hangbin Liu wrote:
>> Hi Steffen,
>>
>> BTW, If we put the check in xfrm_policy_flush(), we can prevent it earlier.
>> But If we put the check in flow_cache_percpu_empty(), we can prevent
>> other functions set fc->percpu to NULL, although not much possible : )
>>
>> So I'm not quite sure whether we should put the check in
>> flow_cache_percpu_empty() or in xfrm_policy_flush().
>
> Can't we just call xfrm_policy_fini() first and then flow_cache_fini()?
>
That would be a better fix. seems safe as what flow_cache_fini does
is only to free fcp->hash_table and stop timer, I didn't see  it has
any dependence on xfrm_policy stuff.

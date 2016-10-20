From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv4: disable BH in set_ping_group_range()
Date: Thu, 20 Oct 2016 14:00:20 -0700
Message-ID: <CAM_iQpX0=OnOfsGg_KGz=--_S+-1TG2=LoAmYVAOSxawCQtBUg@mail.gmail.com>
References: <1476984408.7065.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVFQD0Oqf8YO9HybDpPMhzMMK5m_wNyLwTfVpEwpAVBNw@mail.gmail.com>
 <CAM_iQpVBHa2ujKN1hsU0LT+g899+WEy9a1oBgDj1FmpifPmz6g@mail.gmail.com>
 <CAM_iQpV-00gemayMkdLGzb8wo8CNimOZQHDXrvH1jeN6Svrs8w@mail.gmail.com> <1476996209.7065.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Eric Salo <salo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35083 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755474AbcJTVAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 17:00:43 -0400
Received: by mail-it0-f41.google.com with SMTP id 4so195439241itv.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 14:00:43 -0700 (PDT)
In-Reply-To: <1476996209.7065.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 1:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-10-20 at 12:44 -0700, Cong Wang wrote:
>> On Thu, Oct 20, 2016 at 12:40 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > On Thu, Oct 20, 2016 at 12:32 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> >> On Thu, Oct 20, 2016 at 10:26 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >>> From: Eric Dumazet <edumazet@google.com>
>> >>>
>> >>> In commit 4ee3bd4a8c746 ("ipv4: disable BH when changing ip local port
>> >>> range") Cong added BH protection in set_local_port_range() but missed
>> >>> that same fix was needed in set_ping_group_range()
>> >>
>> >> Don't know why ping_group_range shares the same lock with local_port_range...
>> >> Perhaps just for saving a few bytes, but that is why I missed this place.
>> >
>> > Hold on... We clearly have typos there... Your fix is not correct.
>>
>> We need the attached patch, your patch should be reverted, because
>> unlike local_port_range we never read it in BH context, no need to bother _bh.
>
> Well, we do not change this sysctl very often, so I am not sure why we
> need different seqlocks to protect these ranges.
>
> Seems a waste of space really (per netns)

Error prone vs. space saving, it's up to you...

But clearly current code is still broken even after your patch. I will send
a revert + previous typo fix.

From: Wei Wang <tracywwnj@gmail.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Fri, 18 Mar 2016 14:26:29 -0700
Message-ID: <CAC15z3hhXxTQ+_Y6DaZcd-XVfCdDO9ZcQD6doNNKt-wHjTXAQw@mail.gmail.com>
References: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
	<20160316.195341.68257764618999441.davem@davemloft.net>
	<1458174127.7353.11.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160316.223803.240230703927987310.davem@davemloft.net>
	<1458185652.7353.28.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAM_iQpWG-Pd-qE05B8ETwBMnVGuxVCES-zrL=wyxKAfZwnbwyQ@mail.gmail.com>
	<CAEA6p_CfDYYLf-s0pUy7VNFH+46PDZSXNzUExXRAM_xv2w8tcw@mail.gmail.com>
	<CAM_iQpXgHHr=h=3VeMdYfOnzTdeBeODGVKmwBi7AFW485_WRAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Wang <weiwan@google.com>, Martin KaFai Lau <kafai@fb.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:32988 "EHLO
	mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbcCRV0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 17:26:30 -0400
Received: by mail-vk0-f68.google.com with SMTP id q138so5333616vkb.0
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 14:26:29 -0700 (PDT)
In-Reply-To: <CAM_iQpXgHHr=h=3VeMdYfOnzTdeBeODGVKmwBi7AFW485_WRAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't think ip6_sk_update_pmtu() is a good place to put it as all it
does is to call ip6_update_pmtu(). And ip6_update_pmtu() does the
route lookup and call __ip6_rt_update_pmtu.
We can put it in ip6_update_pmtu(). But that still means we need to
pass sk to ip6_update_pmtu() and I don't think it makes any difference
compared to the current fix.

Thanks.
Wei

On Fri, Mar 18, 2016 at 11:10 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Mar 18, 2016 at 10:45 AM, Wei Wang <weiwan@google.com> wrote:
>> Thanks all for the comments.
>>
>> Cong, you are right that for ipv6, the code does not take care of updating
>> sk_dst_cache entry like Ipv4. And this patch is updating the entry by
>> calling ip6_dst_store() to achieve similar functionality as Ipv4.
>
> My question is why not updating ip6_sk_update_pmtu() to sync with ipv4?

From: Cong Wang <cwang@twopensource.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Fri, 9 Jan 2015 11:37:42 -0800
Message-ID: <CAHA+R7Pi=87b_umrKnd4bsZ+DPkRoTWhNyPwAND5pDzF_3EDaQ@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
	<20150105.193614.1827024424476781168.davem@davemloft.net>
	<CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
	<20150105.195128.794605376092864881.davem@davemloft.net>
	<CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
	<CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com>
	<1420683594.5947.43.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAOxq_8Pp7fwsV3Y+-LNheziQzP8FXqT3ohgMt7SeEs6+nuGxMg@mail.gmail.com>
	<1420695665.5947.44.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAOxq_8OPj4twFg2U93hFNSjeiZ5We5DgeCo-W5hSbXJvQmZfyQ@mail.gmail.com>
	<1420743808.5947.73.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAOxq_8M=Ros56U_VbUVumjS226jHs1DK0A-K9aRksTMu88H_sg@mail.gmail.com>
	<CAHA+R7Ps2_+5NgjE8HNbrTxbjhtt4nJyK9y5HrbHez2PhZEiPQ@mail.gmail.com>
	<CAOxq_8Na14ES1souk-jBa8A=9ArHc-ffRtSd36zbvwHvGM+24Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:34051 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbbAIThm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 14:37:42 -0500
Received: by mail-qc0-f172.google.com with SMTP id m20so10731256qcx.3
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 11:37:42 -0800 (PST)
In-Reply-To: <CAOxq_8Na14ES1souk-jBa8A=9ArHc-ffRtSd36zbvwHvGM+24Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 11:08 AM, Ani Sinha <ani@arista.com> wrote:
>
> Perhaps. What I am truly confused about is :
>
> - We are keeping a sysctl interface that does absolutely nothing in
> the kernel and is completely useless in case some userland
> scripts/tools are rendered broken from it's removal.

I am all for getting rid of it, sane script should always check
the sysctl existence first. I think we did remove some sysctl's
from kernel before.

>
> - surprisingly, we contradict ourselves when we let scripts break when
> running from a child namespace because the  same sysctl is no longer
> available!
>

I am not sure how exactly your script is broken, but it should
test the existence of any /proc file before reading it, even when
you don't use netns, because this could be a new sysctl introduced
recently (probably not the case for ip_rt_max_size, but you get my point).

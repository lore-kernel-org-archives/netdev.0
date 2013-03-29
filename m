From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH] core: fix the use of this_cpu_ptr
Date: Fri, 29 Mar 2013 09:24:37 +0800
Message-ID: <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
	<1364475933.15753.36.camel@edumazet-glaptop>
	<0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f170.google.com ([209.85.220.170]:34762 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567Ab3C2BYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 21:24:38 -0400
Received: by mail-vc0-f170.google.com with SMTP id lf10so131971vcb.15
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 18:24:38 -0700 (PDT)
In-Reply-To: <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/3/28 Christoph Lameter <cl@linux.com>:
> On Thu, 28 Mar 2013, Eric Dumazet wrote:
>
>> > flush_tasklet is not percpu var, and percpu is percpu var, and
>> >     this_cpu_ptr(&info->cache->percpu->flush_tasklet)
>> > is not equal to
>> >     &this_cpu_ptr(info->cache->percpu)->flush_tasklet
>
> &this_cpu_ptr is always an error since you are taking the addresss of an
> address.
>

&this_cpu_ptr()->flush_tasklet,   "->" has high priority than "&"
so the result is same as
 &(this_cpu_ptr()->flush_tasklet)
it should not a issue.

flush_tasklet is not a percpu var, it is a member of percpu var.

-Roy

> this_cpu_ptr(&structure) is the right way to get the address of the cpu
> instance for this cpu for a per cpu structure.
>
>> Christoph, could this kind of error be detected by the compiler or
>> sparse ?
>
> The per cpu variables are marked with __percpu. This should be detected by
> sparse.
>

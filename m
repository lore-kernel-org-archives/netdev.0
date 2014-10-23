From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Wed, 22 Oct 2014 20:48:06 -0700
Message-ID: <1414036086.2094.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
	 <1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuxo7TT+9S1KSHxyTKR+pD6HWJKaTOO=A_VGsZVji3YU2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33328 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932543AbaJWDsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 23:48:08 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so268289pad.31
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 20:48:08 -0700 (PDT)
In-Reply-To: <CAMEtUuxo7TT+9S1KSHxyTKR+pD6HWJKaTOO=A_VGsZVji3YU2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 19:22 -0700, Alexei Starovoitov wrote:

> yes. I was thinking, since dev is already passed
> into __netdev_alloc_skb(), we can check whether
> dev registered with napi via dev->napi_list and if so,
> tell inner __netdev_alloc_frag() to skip irq disabling...
> 

This does not matter. The problem is not _this_ device, the problem is
that another device might trigger a hard irq, and this hard irq could
mess your data.

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] core: fix the use of this_cpu_ptr
Date: Mon, 01 Apr 2013 09:31:27 -0700
Message-ID: <1364833887.5113.161.camel@edumazet-glaptop>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
	 <1364475933.15753.36.camel@edumazet-glaptop>
	 <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
	 <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
	 <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:34172 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758895Ab3DAQba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 12:31:30 -0400
Received: by mail-pb0-f53.google.com with SMTP id un1so1272510pbc.12
        for <netdev@vger.kernel.org>; Mon, 01 Apr 2013 09:31:29 -0700 (PDT)
In-Reply-To: <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-01 at 15:21 +0000, Christoph Lameter wrote:
> On Fri, 29 Mar 2013, RongQing Li wrote:

> > flush_tasklet is not a percpu var, it is a member of percpu var.
> 
> Well then it would be best to use this_cpu_read() instead of this_cpu_ptr.
> It also will generate better code.

I believe we already had this discussion in the past.

flush_tasklet is a structure, and we need its address, not read its
content.

You can not use this_cpu_read() to get its address, and following
code is fine.

tasklet = &this_cpu_ptr(info->cache->percpu)->flush_tasklet;

Similar to this code in mm/page_alloc.c

pcp = &this_cpu_ptr(zone->pageset)->pcp;

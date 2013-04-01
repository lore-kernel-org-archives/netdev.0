From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] core: fix the use of this_cpu_ptr
Date: Mon, 1 Apr 2013 15:21:39 +0000
Message-ID: <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com> <1364475933.15753.36.camel@edumazet-glaptop> <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
 <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a9-78.smtp-out.amazonses.com ([54.240.9.78]:60066 "EHLO
	a9-78.smtp-out.amazonses.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758543Ab3DAP2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 11:28:12 -0400
In-Reply-To: <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Mar 2013, RongQing Li wrote:

> > &this_cpu_ptr is always an error since you are taking the addresss of an
> > address.
> >
>
> &this_cpu_ptr()->flush_tasklet,   "->" has high priority than "&"
> so the result is same as
>  &(this_cpu_ptr()->flush_tasklet)

Ok. This is the same as

	this_cpu_read(xxx.flush_tasklet)

Looks less confusing to me.

> flush_tasklet is not a percpu var, it is a member of percpu var.

Well then it would be best to use this_cpu_read() instead of this_cpu_ptr.
It also will generate better code.

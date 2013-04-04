From: Christoph Lameter <cl@linux.com>
Subject: Re: [PERCPU] Remove & in front of this_cpu_ptr
Date: Thu, 4 Apr 2013 13:52:00 +0000
Message-ID: <0000013dd5517d80-151c27ac-ebf3-4ec7-bcd4-c85a7975852e-000000@email.amazonses.com>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com> <1364475933.15753.36.camel@edumazet-glaptop> <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com> <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
 <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com> <1364833887.5113.161.camel@edumazet-glaptop> <alpine.DEB.2.02.1304031540110.3444@gentwo.org> <0000013dd1a300fb-1fbb26a9-77a7-4c24-95ff-f088309206d9-000000@email.amazonses.com>
 <20130403212450.GD3411@htj.dyndns.org> <1365024575.13853.39.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tejun Heo <htejun@gmail.com>, RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a9-62.smtp-out.amazonses.com ([54.240.9.62]:34703 "EHLO
	a9-62.smtp-out.amazonses.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761192Ab3DDOE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:04:57 -0400
In-Reply-To: <1365024575.13853.39.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Apr 2013, Eric Dumazet wrote:

> I agree with you, I prefer &this_cpu_ptr(percpu_pointer)->field
>
> The offset is added after getting the address of the (percpu) base
> object.

There are two offsets being added! percpu_pointer is not a
pointer but an offset. this_cpu_ptr creates a pointer from the
percpu base of the current processor by adding the offset of the percpu
variable. The offset calculation better be in the parenthesis.

The method that I proposed is also conforming with the use of other
this_cpu_ops. F.e. In order to do a read one would need to do

x = this_cpu_read(percpu_pointer->field)




x = this_cpu_read(percpu_pointer)->field

does not work (and does not pass sparse).

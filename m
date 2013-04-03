From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PERCPU] Remove & in front of this_cpu_ptr
Date: Wed, 3 Apr 2013 14:24:50 -0700
Message-ID: <20130403212450.GD3411@htj.dyndns.org>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
 <1364475933.15753.36.camel@edumazet-glaptop>
 <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
 <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
 <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com>
 <1364833887.5113.161.camel@edumazet-glaptop>
 <alpine.DEB.2.02.1304031540110.3444@gentwo.org>
 <0000013dd1a300fb-1fbb26a9-77a7-4c24-95ff-f088309206d9-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:33813 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760497Ab3DCVYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 17:24:55 -0400
Received: by mail-pd0-f173.google.com with SMTP id v14so846673pde.4
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 14:24:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <0000013dd1a300fb-1fbb26a9-77a7-4c24-95ff-f088309206d9-000000@email.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Christoph.

On Wed, Apr 03, 2013 at 08:42:33PM +0000, Christoph Lameter wrote:
> Subject: percpu: Remove & in front of this_cpu_ptr
> 
> Both
> 
> 	this_cpu_ptr(&percpu_pointer->field)
> 
> 
> [Add Offset in percpu pointer to the field offset in the struct
> and then add to the local percpu base]
> 
> as well as
> 
> 	 &this_cpu_ptr(percpu_pointer)->field
> 
> [Add percpu variable offset to local percpu base to form an address
> and then add the field offset to the address].
> 
> are correct. However, the latter looks a bit more complicated.
> The first one is easier to understand. The second one may be
> more difficult for the compiler to optimize as well.

I don't know about this one.  I actually prefer the latter in that the
pointer being passed into this_cpu_ptr() is something which is the
actual percpu pointer either from variable declaration or the
allocator.  Sure, they both are just different expressions of the same
thing but the former requires an extra guarantee from percpu subsystem
that the accessors would work for pointers which aren't the exact
values defined or allocated.  I'd much prefer unfiying things toward
the latter than the former.

Thanks.

-- 
tejun

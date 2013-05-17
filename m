From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: can call module_free() from
 any context
Date: Fri, 17 May 2013 15:22:46 -0700
Message-ID: <1368829366.3301.121.camel@edumazet-glaptop>
References: <1368769530.3301.81.camel@edumazet-glaptop>
	 <20130517.141952.581871611521516663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@ZenIV.linux.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36012 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756915Ab3EQWWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 18:22:47 -0400
Received: by mail-pd0-f175.google.com with SMTP id y14so3708724pdi.6
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 15:22:47 -0700 (PDT)
In-Reply-To: <20130517.141952.581871611521516663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 14:19 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 16 May 2013 22:45:30 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > It looks like we can call module_free()/vfree() from softirq context,
> > so no longer need a wrapper and a work_struct.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.

Thanks David

I am considering adding ReadOnly protection to the pages containing BPF
generated code, like we do for modules text if
CONFIG_DEBUG_SET_MODULE_RONX=y

Should we have an option to configure this, driven by HAVE_BPF_JIT_RO,
or should we do the RO thing in all cases (ie not adding yet another
Kconfig stuff)



Another ongoing work is to add some protection against BPF JIT spraying
attacks
( http://mainisusuallyafunction.blogspot.com/2012/11/attacking-hardened-linux-systems-with.html )

My idea would be to have a hole of random size before the code, filled
with 0xcc (int3) opcodes. Since we allocate a multiple of PAGE_SIZE
anyway, we have plenty of available space to play with.
